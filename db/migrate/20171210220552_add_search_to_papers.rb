class AddSearchToPapers < ActiveRecord::Migration[5.1]
  def up
    add_column :papers, :tsv, :tsvector
    add_index :papers, :tsv, using: "gin"

    execute <<-SQL
      create trigger paper_search_update before insert or update
      on papers for each row execute procedure
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', title, body, authors, citation_string, repository_url, doi, archive_doi
      );
    SQL

    # This looks like a no-op, but it invokes the trigger function on all rows
    execute <<-SQL
      update papers set title = title;
    SQL
  end

  def down
    remove_column :papers, :tsv
    remove_index :papers, :tsv

    execute <<-SQL
      drop trigger paper_search_update on papers;
    SQL
  end
end
