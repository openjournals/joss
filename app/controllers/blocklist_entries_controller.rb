class BlocklistEntriesController < ApplicationController
  before_action :require_aeic

  def index
    @entries = BlocklistEntry.includes(:editor).order(created_at: :desc)
    @new_entry = BlocklistEntry.new
  end

  def create
    entry = BlocklistEntry.new(entry_params)
    entry.editor = current_user.editor

    if entry.save
      flash[:notice] = "Added #{entry.display_value} to the block list."
    else
      flash[:error] = "Could not add to the block list: #{entry.errors.full_messages.to_sentence}"
    end

    redirect_back fallback_location: blocklist_entries_path
  end

  # Block the submitter's ORCID iD, email and repository owner in one go.
  def block_paper
    paper = Paper.find_by_sha!(params[:paper_sha])
    reason = params[:reason].to_s.strip

    if reason.blank?
      flash[:error] = "Please give a reason for the block."
    else
      created, failed = BlocklistEntry.block_all_for(paper, editor: current_user.editor, reason: reason)

      if created.any?
        flash[:notice] = "Blocked #{created.map(&:display_value).to_sentence}."
      elsif failed.empty?
        flash[:notice] = "Nothing to do: everything for this submission was already blocked."
      end
      flash[:error] = "Could not block #{failed.map(&:display_value).to_sentence}: #{failed.flat_map { |f| f.errors.full_messages }.uniq.to_sentence}" if failed.any?
    end

    redirect_to "/papers/#{paper.sha}/admin"
  end

  def destroy
    entry = BlocklistEntry.find(params[:id])
    entry.destroy!
    flash[:notice] = "Removed #{entry.display_value} from the block list."
    redirect_to blocklist_entries_path
  end

  private

  def entry_params
    params.require(:blocklist_entry).permit(:kind, :value, :reason)
  end
end
