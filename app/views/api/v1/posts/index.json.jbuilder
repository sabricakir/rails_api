json.paging do
  # json.extract! @pagy_metadata, :prev_url, :next_url, :last_url, :items, :page, :prev, :next, :pages
  json.prev_url @pagy_metadata[:prev_url]
  json.next_url @pagy_metadata[:next_url]
  json.prev_page @pagy_metadata[:prev]
  json.next_page @pagy_metadata[:next]
  json.total_pages @pagy_metadata[:pages]
  json.total_items_count @pagy_metadata[:count]
end

json.data do
  json.array! @posts, partial: 'api/v1/posts/post', as: :post
end
