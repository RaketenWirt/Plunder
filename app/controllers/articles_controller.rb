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
    @article = Article.new(article_params.merge(:user_id => current_user.id))
    @article.save
    #render :action => 'crop'
    respond_with(@article)
  end

  def update
    @article.update(article_params)
    #respond_with(@article)
    @article.avatar = params[:avatar] if params[:avatar] != nil
    @article.save
    #if params[:article][:avatar].blank?
      respond_with(@article)
    #elsif params[:crop_x] == nil
    #  render :action => 'crop', :id => params[:id], :crop_x => params[:article][:crop_x]
    #end


  end



  # def reprocess_avatar
  #   avatar.reprocess!
  #   crop_x = nil
  #   redirect_to random_article_path
  # end

  def destroy
    @article.destroy
    respond_with(@article)
  end

  #def crop_attached_file

  #end


  def random
    othersArticles = Article.where.not(:user_id => current_user.id)
    matchedByMe = Match.where(:user_id => current_user.id).pluck(:favorite_id)

    @random_article = othersArticles.where.not(:id => matchedByMe).order("RANDOM()").first

  end

  def like
    # favorite Others article and like it
    current_user.favorites << Article.find(params[:id])
    if params[:choice] == "yes"
      current_match = Match.where(:user_id => current_user).where(:favorite_id => params[:id]).first
      current_match.like = true
      current_match.save

      #add Exchange Items
      Exchange.add_exchange_items current_match, current_user.id
    end

    go_back
  end

  def matches
    @exchanges_for_view = []
    Exchange.matched_users(current_user.id).each do |other|
      
      exchanges_per_user = []
      Exchange.with_this_user(current_user.id, other).each do |ex|
          
        users_articles = Exchange.get_users_article(ex, current_user.id)
        hash = {other: users_articles[1], my: users_articles[0], state: Exchange.get_state(ex, current_user.id)}
        exchanges_per_user.push(hash)
      end
      @exchanges_for_view.push(exchanges_per_user)
     end
  end

  def exchange_handler
    ex = Exchange.actual(params[:id1], params[:id2])

    if ex.user_1 == current_user.id
      my_article = ex.article_id_1
      other_user = ex.user_2
      other_article = ex.article_id_2
    else
      my_article = ex.article_id_2
      other_user = ex.user_1
      other_article = ex.article_id_1
    end

    Exchange.state_handler(ex, params[:state], params[:choice], current_user.id, other_user, my_article, other_article)
    go_back
  end

  def delete_exchange
    Exchange.actual(params[:id1], params[:id2]).destroy
  end

  private

  def go_back
    session[:return_to] ||= request.referer
    redirect_to session.delete(:return_to)
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:name, :user_id, :avatar, :description, :shippable, :crop_x)
  end
end
