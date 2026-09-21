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
