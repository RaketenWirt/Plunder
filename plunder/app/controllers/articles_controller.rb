class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @articles = Article.all
    respond_with(@articles)
  end

  def show
    respond_with(@article)
  end

  def new
    @article = Article.new
    respond_with(@article)
  end

  def edit
  end

  def create
    #article_params
    @article = Article.new(article_params.merge(:user_id => current_user.id))
    @article.save
    respond_with(@article)
  end

  def update
    @article.update(article_params)
    respond_with(@article)
  end

  def destroy
    @article.destroy
    respond_with(@article)
  end



  def matches

    
    @currentUser = current_user.id
    # Alle eigenen Artikel
    ownProducts = Article.where(:user_id => @currentUser)

    # Ids aller Artikel die ich like
    likedFavoriteIds = Match.where(:like => true, :user_id => @currentUser).pluck(:favorite_id)
    # Alle Artikel die ich like
    favoritedProducts = Article.where(:id => likedFavoriteIds)
    # Alle User von denen ich Artikel like
    favoritedUsers = User.joins(:articles).where(:articles => {:id => favoritedProducts}).distinct

    # Ids aller User die Artikel von mir liken
    likeingUsersIds = Match.where(:like => true, :favorite_id => ownProducts).pluck(:user_id)
    # Alle User die Artikel von mir liken
    likeingUser = User.where(:id => likeingUsersIds)


    # Alle User mit denen ich Matches habe
    @matchedUsers = (favoritedUsers & likeingUser)

    # Alle Produkte von gematchen Usern
    #producstFromMatchedUser = Article.joins(:users).where(:user => {:id => @matchedUsers})

    # Inhalt soll ein User mit allen Matches sein
    @matches = []

    # Schleife über alle User mit matches
    @matchedUsers.each do |matchedUser|

      # Alle Produkte eines Users
      productsFromMatchedUser = Article.where(:user_id => matchedUser)

      # Ids aller Produkte die dieser User liked
      likeingFavoriteIds = Match.where(:like => true, :user_id => matchedUser).pluck(:favorite_id)
      # Alle Produkte die der User liked
      likeingProducts = Article.where(:id => likeingFavoriteIds)

      # Alle Produkte die ich von diesem User like
      myMatches = (productsFromMatchedUser & favoritedProducts)

      # Alle Produkte die der User von mir liked
      otherMatches = (ownProducts & likeingProducts)

      # Inhalt sollen alle gegenüberstellungen von Artikeln sein
      array = []

      # Doppelte Schleife zur gegenüberstellung aller Artikel
      myMatches.each do |my|
        otherMatches.each do |other|

          

          #---------- State Handling ---------------------------
          actualExchange = Exchange.where(:article_id_1 => [my.id,other.id], :article_id_2 => [my.id,other.id])

            # Feststellung welcher User ich bin, und welcher der andere ist.
            if actualExchange.user_1 == current_user
              user_1 = actualExchange.user_1
              user_2 = actualExchange.user_2
            else
              user_1 = actualExchange.user_2
              user_2 = actualExchange.user_1
            end
          
          # setzen der states
          if actualExchange.accept_1 == true && actualExchange.accept_2 == nil
            state = "iAccepted"
          elsif actualExchange.accept_2 == true && actualExchange.accept_1 == nil
            state = "accepted"
          elsif actualExchange.accept_1 == false && actualExchange.accept_2 == nil
            state = "iRejected"
          elsif actualExchange.accept_2 == false && actualExchange.accept_2 == nil
            state = "rejected"
          elsif actualExchange.accept_1 == true && actualExchange.accept_2 == true
            state = "bothAccepted"  
          elsif actualExchange.accept_1 == false && actualExchange.accept_2 == false
            state = "bothRejected"
          else
            state = "neutral"
          end  

          #----------------------------------------
          # Weitergabe des Matching Paares als Hash
          hash = { :other => my, :my => other, :state => state}
          array.push(hash)

        end
      end

      @matches.push(array)

    end
  end

  # Führt je nach Status und gedrückten Button, Datenbankoperationen aus 
  def exchangeHandler 
    action = params[:action]
    state = params[:state]

    case state
    when "accepted"

    when "rejected"

    when "iAccepted"

    when "iRejected"

    when "bothAccepted"

    when "neutral"

    else  
    end
  end


  def random
    othersArticles = Article.where.not(:user_id => current_user.id)
    matchedByMe = Match.where(:user_id => current_user.id).pluck(:favorite_id)

    @random_article = othersArticles.where.not(:id => matchedByMe).order("RANDOM()").first

    #@random_article = Article.joins("LEFT OUTER JOIN matches ON articles.id = matches.favorite_id ").all.distinct #.order("RANDOM()")

  end

  private
    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:name, :description, :shippable)
    end
end
