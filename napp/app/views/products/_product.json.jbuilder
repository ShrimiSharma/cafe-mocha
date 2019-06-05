json.extract! product, :id, :asin, :name, :rank, :product_dimensions, :created_at, :updated_at
json.url product_url(product, format: :json)
