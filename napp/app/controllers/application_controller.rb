  class ApplicationController < ActionController::Base
  #require 'json'

    def get_asin

      render template:'get_asin'

    end

    def scrape_amazon

      if params[:q].present?
        @asin = "#{params[:q]}" 
        
        require 'open-uri'
        require 'watir'
        
      begin

        browser = Watir::Browser.new :chrome, headless:true
        browser.goto "https://www.amazon.com/dp/#@asin?th=1"
        sleep 2
      
        @doc = Nokogiri::HTML(browser.html)
				#puts @doc.inspect
        
        unless @doc.nil?
         @title = @doc.at("#titleSection").text.strip #unless @doc.at("titleSection").nil?
         @category = @doc.at("#wayfinding-breadcrumbs_container").text.strip #unless @doc.at("#wayfinding-breadcrumbs_container").nil?
        
         prod_details = @doc.css("div#prodDetails")
         puts prod_details.inspect
					
					if prod_details.nil?
						prod_details = @doc.css("div#descriptionAndDetails")
					end
          
          @dimensions = prod_details.at(':contains("Dimensions"):not(:has(:contains("Dimensions")))').next_element.text.strip unless prod_details.at(':contains("Dimensions"):not(:has(:contains("Dimensions")))').nil?
          @rank = prod_details.at(':contains("Best Sellers Rank"):not(:has(:contains("Best Sellers Rank")))').next_element.text.strip.split("(")[0] unless prod_details.at(':contains("Best Sellers Rank"):not(:has(:contains("Best Sellers Rank")))').nil?
          
       

        #check if product exists in the db, create a new product if it doesn't already exist.
        @pr = Product.find_by_asin(@asin)
        if @pr.nil?
          @p = Product.new
          @p.name = @title
          @p.asin = @asin
          @p.product_dimensions = @dimensions
          @p.category = @category
          @p.rank = @rank
          if @p.save!
            #puts @p.id
            redirect_to @p
          else
            flash["Sorry product could not be saved."]
            render template: 'get_asin'
          end
        
        else
          redirect_to @pr, notice: 'Product already exits.'
        end
          
        end
      
  rescue OpenURI::HTTPError => e
    if e.message == '404 Not Found'
      raise ActionController::RoutingError.new('Could not find this product on Amazon. Please enter a valid ASIN.')
    else
      redirect_to root_path, notice: 'Please enter a valid ASIN.'
    end

  end

  else
    redirect_to root_path, notice: 'Please enter a valid ASIN.' 
  end

  end
end
