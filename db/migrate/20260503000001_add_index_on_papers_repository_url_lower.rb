class AddIndexOnPapersRepositoryUrlLower < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_papers_on_lower_repository_url ON papers (lower(repository_url))"
  end

  def down
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_papers_on_lower_repository_url"
  end
end
