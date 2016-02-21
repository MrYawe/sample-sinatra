# myapp.rb
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'ostruct'


# Récupère l'article
def getArticle(filename)
  id = filename.gsub(/[^0-9]/, '') # recupère le nombre dans le nom du fichier
  title, img, *body_ary = IO.readlines(filename)
  body = body_ary.join("<br>")
  return OpenStruct.new(:id => id, :img => img, :title => title, :body => body)
end

get '/' do

  (params['page'].nil? || params['page'].to_i<1 || params['page'].to_i>3) ? page=0 : page=params['page'].to_i-1 #peut être amélioré mais ce n'est qu'une demo
  filenames = Dir.glob('articles/*')
  articles = filenames.sort.reverse.inject([]) { |res, filename|
    article = getArticle(filename)
    article.body.gsub!(/^(.{100,}?).*$/m,'\1...') # gsub : tronque à 100 caractères et ajoute '...'
    res.push(article)
  }

  haml :home, :locals => {articles:articles[page*3, 3], page:page+1}
end

get '/articles/:id' do

  filenames = Dir.glob("articles/#{params['id']}.txt")
  pass unless filenames.any? # ne match pas la route si aucun article n'est trouvé (lance une 404)

  haml :article, :locals => {article:getArticle(filenames[0])}
end