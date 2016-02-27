# myapp.rb
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'ostruct'

#constants
ARTICLE_PER_PAGE = 3

# Récupère l'article
def getArticle(filename)
  id = filename.gsub(/[^0-9]/, '') # recupère le nombre dans le nom du fichier
  title, image, *body_ary = IO.readlines(filename) # lignes : (1)=title, (2)=image, (>2)=body
  body = body_ary.join("<br>")
  return OpenStruct.new(:id => id, :image => image, :title => title, :body => body)
end

get '/' do

  filenames = Dir.glob('articles/*')
  articles = filenames.sort.reverse.inject([]) { |res, filename|
    article = getArticle(filename)
    article.body.gsub!(/^(.{100,}?).*$/m,'\1...') # gsub : tronque à 100 caractères et ajoute '...'
    res.push(article)
  }

  page = OpenStruct.new(:max => (articles.length.to_f/ARTICLE_PER_PAGE).ceil) # max = le nombre total de page (ou la plus grande page)
  (params['page'].nil? || params['page'].to_i<1 || params['page'].to_i>page.max) ? page.current=1 : page.current=params['page'].to_i

  haml :home, :locals => {articles: articles[(page.current-1)*ARTICLE_PER_PAGE, ARTICLE_PER_PAGE], page: page}
end

get '/articles/:id' do

  filenames = Dir.glob("articles/#{params['id']}.txt")
  pass unless filenames.any? # ne match pas la route si aucun article n'est trouvé (lance une 404)

  haml :article, :locals => {article:getArticle(filenames[0])}
end