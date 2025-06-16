class SearchService
  # Initialize the search service
  #
  # @param record_class [Class] The ActiveRecord model class to search.  e.g. Post
  # @param searchable_columns [Array<String>] Array of column names to search in the main table.  e.g. ["title", "excerpt"]
  # @param options [Hash] Additional search options
  # @option options [Hash] :searchable_associations Hash of associations to search through
  #   Format: { association_name: ["column1", "column2"] }.  e.g. { rich_text_description: ["body"] }
  #   For rich text fields, use: { "rich_text_#{field_name}": ["body"] }.  e.g. { rich_text_description: ["body"] }
  #   Example: { rich_text_description: ["body"], comments: ["body"] }
  # @option options [Integer] :limit Maximum number of results to return
  def initialize(record_class, searchable_columns, options = {})
    @record_class = record_class
    @searchable_columns = searchable_columns
    @searchable_associations = options[:searchable_associations] || {}
    @limit = options[:limit]
  end

  def search(query)
    return @record_class.none if query.blank?

    base_query = @record_class.all

    # Search in direct columns
    column_conditions = @searchable_columns.map do |column|
      "#{@record_class.table_name}.#{column} ILIKE :query"
    end

    # Search in associations
    association_conditions = []
    @searchable_associations.each do |association, columns|
      case association.to_s
      when /^rich_text_(.+)$/
        # Special handling for Action Text
        field_name = $1
        base_query = base_query.joins("INNER JOIN action_text_rich_texts ON action_text_rich_texts.record_type = '#{@record_class.name}' AND action_text_rich_texts.name = '#{field_name}' AND action_text_rich_texts.record_id = #{@record_class.table_name}.id")
        columns.each do |column|
          association_conditions << "action_text_rich_texts.#{column} ILIKE :query"
        end
      else
        # Handle regular associations
        base_query = base_query.joins(association)
        columns.each do |column|
          association_conditions << "#{association}.#{column} ILIKE :query"
        end
      end
    end

    # Combine all conditions
    all_conditions = (column_conditions + association_conditions).join(" OR ")

    # Execute the search with limit if specified
    results = base_query.where(all_conditions, query: "%#{query}%").distinct
    @limit ? results.limit(@limit) : results
  end
end
