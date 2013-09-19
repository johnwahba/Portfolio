projects = [
  
  ["https://github.com/johnwahba/chess",
   "Modular chess game in JQuery which accepts various rulebooks players in Co"\
   "ffeescript. AI uses negamax with basic board scoring.",
    "Chess", "http://www.johnawahba.com/chess", 
    "chess", "Chess.png"],

  ["https://github.com/johnwahba/legalbacon",
   "Graphing of Supreme Court opinions of the past 100 years parsed with regex"\
   " and Nokogiri. Graph traversal to map cross citations. Twitter Bootstrap. "\
   "Ruby on Rails. Custom SQL queries. Views organized in HAML templates",
   "Legal Bacon", "http://www.legalbacon.com", "legal-bacon", "LegalBacon.png"],

  ["https://github.com/johnwahba/portfolio", "This is my personal portfolio wh"\
   "ich you are currently on... meta",
   "Portfolio", "http://www.johnawahba.com", "portfolio", ]
]

projects.each do |git_url, summary, title, url, slug, picture_url|
  Project.create!({git_url: git_url, summary: summary, title: title, url: url, 
    slug: slug , picture_url: picture_url})
end