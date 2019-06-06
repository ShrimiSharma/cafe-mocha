  class ApplicationController < ActionController::Base
  #require 'json'

  def get_asin

    render template:'get_asin'

  end

  def scrape_amazon

    if params[:q].present?
      @asin = "#{params[:q]}" 

      require 'open-uri'
    begin

      #@asin = 'B002QYW8LW'
      @doc = Nokogiri::HTML(open("https://www.amazon.com/dp/#@asin?th=1", 'User-Agent' => 'Ruby'))#{|conf| conf.noblanks}
#       puts @doc.inspect
      unless @doc.nil?
        @title = @doc.at("#titleSection").text.strip
        @category = @doc.at("#wayfinding-breadcrumbs_container").text.strip
        
        prod_details = @doc.css("div#prodDetails")
        puts"#############################"
       
        prod_details.each do |pd|
          @dimensions = pd.at(':contains("Dimensions"):not(:has(:contains("Dimensions")))').next_element.text.strip
          puts @dimensions.inspect
          @rank = pd.at(':contains("Best Sellers Rank"):not(:has(:contains("Best Sellers Rank")))').next_element.text.strip.split("(")[0]
          puts @rank.inspect
        end
        
        if prod_details.nil? || prod_details.empty?
          #do what??
          dim = @doc.xpath('//span[contains(text(), "Dimensions")]').first
          puts dim.inspect
          unless dim.nil? 
            @dimensions = dim.next_element.text.strip
          end
          ra = @doc.xpath('//*[contains(text(), "Best Sellers Rank")]')[0]
          unless ra.nil?
            @rank = ra.next_element.text#.strip#.split("(")[0]
          end
          #@rank = @doc.xpath('//* [contains(text(), "Best Sellers Rank")]')[0].next_element.text.strip.split("(")[0]
        end

#         dim = @doc.at(':contains("Product Dimensions"):not(:has(:contains("Product Dimensions")))')
#         unless dim.nil?
#           puts "Here1 dim"
#           puts dim.inspect
#            @dimensions = dim.next.text.strip
#         end
#         #@dimensions = @doc.at(':contains("Product Dimensions"):not(:has(:contains("Product Dimensions")))').next.text.strip
#         if @dimensions.nil? || @dimensions.empty?
#           dim = @doc.xpath('//span[contains(text(), "Product Dimensions")]').first
#           puts "Here 2 dim"
#           puts dim.inspect
#           unless dim.nil? 
#             @dimensions = dim.next_element.text.strip
#           end
#           #@dimensions = @doc.xpath('//span[contains(text(), "Product Dimensions")]').first.next_element.text.strip
#         end

#         #@rank = @doc.at(':contains("Best Sellers Rank"):not(:has(:contains("Best Sellers Rank")))').next.text.strip.split("(")[0]
#         #@rank = @doc.xpath('//* [contains(text(), "Best Sellers Rank")]')[0].next_element.text.strip.split("(")[0]
#         #@rank = @doc.search "[text()*='Best Sellers Rank']"
#         @rank = @doc.search('Best Sellers Rank').text[/\#.*\)/]
#         puts "here i am"
#         puts @dimensions.inspect
#         puts @rank.inspect

        #check if product exists in the db, create a new product if it doesnt already exist.
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


     #puts @ranks.inspect
      #puts @tble.inspect
      #puts "here"
      #puts @dimensions.inspect
      #puts @rank.inspect
      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          raise ActionController::RoutingError.new('Could not find this product on Amazon. Please enter a valid ASIN.')
  else
    redirect_to root_path, notice: 'Please enter a valid ASIN.'
  end

    end

      #render template: 'get_asin'
     else
      redirect_to root_path, notice: 'Please enter a valid ASIN.' 
     end

  end

  end
