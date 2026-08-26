module ScopeReview
  # License identification. For GitHub-hosted repositories the Runner passes
  # in the SPDX id GitHub computed (GitHub runs licensee server-side —
  # authoritative). For other hosts we fall back to matching distinctive
  # phrases in the LICENSE file. Unrecognisable ≠ missing: tri-state output
  # so an unusual-but-real license escalates to a human instead of failing.
  class LicenseDetector
    OSI_APPROVED = %w[
      MIT Apache-2.0 BSD-2-Clause BSD-3-Clause BSD-3-Clause-Clear 0BSD ISC
      GPL-2.0 GPL-2.0-only GPL-2.0-or-later GPL-3.0 GPL-3.0-only GPL-3.0-or-later
      LGPL-2.1 LGPL-2.1-only LGPL-2.1-or-later LGPL-3.0 LGPL-3.0-only LGPL-3.0-or-later
      AGPL-3.0 AGPL-3.0-only AGPL-3.0-or-later
      MPL-1.1 MPL-2.0 EPL-1.0 EPL-2.0 Artistic-2.0 Zlib BSL-1.0
      EUPL-1.1 EUPL-1.2 CECILL-2.1 NCSA PostgreSQL OFL-1.1 Unlicense
      Python-2.0 AFL-3.0 OSL-3.0 CDDL-1.0 UPL-1.0 MulanPSL-2.0 BlueOak-1.0.0
    ].to_set.freeze

    # Known-present but NOT OSI-approved (definite fail, not unknown).
    KNOWN_NOT_OSI = %w[
      CC0-1.0 CC-BY-4.0 CC-BY-SA-4.0 CC-BY-NC-4.0 WTFPL Beerware
      proprietary custom no-license
    ].to_set.freeze

    LICENSE_BASENAMES = /\A(un)?licen[cs]e(\.(md|txt|rst))?\z|\Acopying(\.(md|txt))?\z/i

    PHRASE_PATTERNS = [
      [/Permission is hereby granted, free of charge/i, "MIT"],
      [/Apache License,?\s+Version 2\.0/i, "Apache-2.0"],
      [/GNU AFFERO GENERAL PUBLIC LICENSE.*Version 3/im, "AGPL-3.0"],
      [/GNU LESSER GENERAL PUBLIC LICENSE.*Version 3/im, "LGPL-3.0"],
      [/GNU LESSER GENERAL PUBLIC LICENSE.*Version 2\.1/im, "LGPL-2.1"],
      [/GNU GENERAL PUBLIC LICENSE.*Version 3/im, "GPL-3.0"],
      [/GNU GENERAL PUBLIC LICENSE.*Version 2/im, "GPL-2.0"],
      [/Mozilla Public License,?\s+v(ersion)?\.?\s*2\.0/i, "MPL-2.0"],
      [/Redistribution and use in source and binary forms.*neither the name/im, "BSD-3-Clause"],
      [/Redistribution and use in source and binary forms/i, "BSD-2-Clause"],
      [/Eclipse Public License.*v(ersion)?\.?\s*2\.0/im, "EPL-2.0"],
      [/Boost Software License.*Version 1\.0/im, "BSL-1.0"],
      [/This is free and unencumbered software released into the public domain/i, "Unlicense"],
      [/CC0 1\.0 Universal/i, "CC0-1.0"],
      [/Creative Commons Attribution/i, "CC-BY-4.0"],
      [/European Union Public Licence.*[Vv]\.?\s*1\.2/m, "EUPL-1.2"],
      [/CeCILL/i, "CECILL-2.1"],
      [/Internet Systems Consortium|ISC License/i, "ISC"],
    ].freeze

    # host_spdx: SPDX id reported by the hosting platform, if any. GitHub
    # reports NOASSERTION when a license file exists but couldn't be
    # classified — that is "unidentified", not "not open source", so we fall
    # through to local detection (and ultimately to unknown, which escalates).
    def self.detect(dir, relative_paths, host_spdx: nil)
      host_spdx = nil if host_spdx.to_s.casecmp?("NOASSERTION")
      spdx = host_spdx.presence || local_spdx(dir, relative_paths)
      license_file = license_file_in(relative_paths)

      {
        spdx_id: spdx,
        file: license_file,
        # true / false / nil(=unknown, escalate): a license file we can't
        # identify is unknown, not a failure.
        osi_approved: osi_status(spdx, license_file),
      }
    end

    def self.osi_status(spdx, license_file)
      return true if spdx && OSI_APPROVED.include?(spdx)
      return false if spdx && KNOWN_NOT_OSI.include?(spdx)
      return false if spdx.nil? && license_file.nil? # no license at all

      nil
    end

    def self.license_file_in(relative_paths)
      relative_paths.find { |p| !p.include?("/") && File.basename(p).match?(LICENSE_BASENAMES) }
    end

    def self.local_spdx(dir, relative_paths)
      file = license_file_in(relative_paths)
      return nil unless file

      path = File.join(dir, file)
      return nil unless File.file?(path) && File.size(path) < 256 * 1024

      text = File.read(path, encoding: "UTF-8").scrub
      PHRASE_PATTERNS.find { |re, _| text.match?(re) }&.last
    rescue Errno::ENOENT, Errno::EACCES
      nil
    end
  end
end
