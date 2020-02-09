class CreateHistoryRecord < ApplicationService
  def initialize(user:, search_params:, results_size:)
    @user = user
    @search_params = search_params
    @results_size = results_size
  end

  def call
    build_record
    save_record
  end

  private
    def build_record
      filter_values = @search_params.values[2..]
      data = { inquiry: @search_params[:inquiry].strip.downcase,
       query_type: @search_params[:query_type],
       filters: filter_values,
       custom_filters: !filter_values.map {|f| f == '1'}.all?,
       results: @results_size }
      @record = @user.records.build(data)
    end

    def save_record
      @record.save
    end
end
