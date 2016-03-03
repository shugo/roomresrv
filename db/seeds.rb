Office.create!([
  {name: "松江本社"},
  {name: "東京支社"}
])
Room.create!([
  {office_id: 1, name: "小部屋応接"},
  {office_id: 1, name: "大部屋"},
  {office_id: 1, name: "キッチン"},
  {office_id: 2, name: "会議室"}
])
