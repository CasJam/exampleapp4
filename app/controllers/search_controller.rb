class SearchController < ApplicationController
  def search
    query = params[:query]

    search_service = SearchService.new(
      Post,
      [ "title" ]
    )

    @results = search_service.search(query)

    respond_to do |format|
      format.turbo_stream
    end
  end
end
