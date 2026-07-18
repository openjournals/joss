require "open3"
require "tmpdir"
require "fileutils"
require "timeout"

module ScopeReview
  # Clones a submission repository into a temporary directory and yields the
  # working copy path. Full history is required (dump detection diffs the whole
  # history), so no --depth and no blob filters — a partial clone would lazily
  # re-fetch blobs one by one during the numstat pass. Host-agnostic: plain
  # `git clone`, never `gh`.
  #
  # Oversize protection for GitHub repos happens before this class is called
  # (API pre-flight in Runner); the clone timeout here is the backstop for
  # hosts where size can't be checked in advance.
  class Checkout
    class CloneError < StandardError; end
    class CloneTimeout < CloneError; end

    def self.clone(repo_url, branch: nil, timeout: nil)
      timeout ||= ScopeReview.config(:clone_timeout, 600)
      dir = Dir.mktmpdir("scope-review-")
      status, stderr = run_clone(repo_url, dir, branch, timeout)

      # The recorded branch may be wrong or stale ("main" vs "master"): retry
      # on the repository's default branch before giving up.
      if !status&.success? && branch.present?
        FileUtils.remove_entry(dir) if File.directory?(dir)
        dir = Dir.mktmpdir("scope-review-")
        status, stderr = run_clone(repo_url, dir, nil, timeout)
      end

      unless status&.success?
        raise CloneError, "git clone failed for #{repo_url}: #{stderr.to_s.lines.first&.strip}"
      end

      yield dir
    ensure
      FileUtils.remove_entry(dir) if dir && File.directory?(dir)
    end

    def self.run_clone(repo_url, dir, branch, timeout)
      args = %w[git clone --quiet]
      args += ["--branch", branch] if branch.present?
      args += ["--", repo_url, dir]

      stderr_r, stderr_w = IO.pipe
      # GIT_TERMINAL_PROMPT=0: a private/nonexistent repo must fail fast, not
      # hang waiting for credentials.
      pid = Process.spawn({ "GIT_TERMINAL_PROMPT" => "0" }, *args,
                          out: File::NULL, err: stderr_w, pgroup: true)
      stderr_w.close

      status = nil
      begin
        Timeout.timeout(timeout) { _, status = Process.wait2(pid) }
      rescue Timeout::Error
        begin
          Process.kill("KILL", -Process.getpgid(pid))
        rescue Errno::ESRCH, Errno::EPERM
        end
        Process.wait(pid) rescue nil
        raise CloneTimeout, "git clone timed out after #{timeout}s for #{repo_url}"
      end

      [status, stderr_r.read]
    ensure
      [stderr_r, stderr_w].compact.each { |io| io.close unless io.closed? }
    end
    private_class_method :run_clone
  end
end
