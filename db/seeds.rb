unless Office.where(name: "松江本社").first
  matsue = Office.create!(name: "松江本社")
  tokyo = Office.create!(name: "東京支社")
  Room.create!([
    {office: matsue, name: "小部屋応接"},
    {office: matsue, name: "大部屋"},
    {office: matsue, name: "キッチン"},
    {office: matsue, name: "小部屋隅テーブル"},
    {office: tokyo, name: "会議室"}
  ])
else
  puts "Do nothing"
end
