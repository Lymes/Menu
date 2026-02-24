import Foundation

let menu1Content = """
**Sandwiches**

Ciabatta Brötchen mit luftgetrockneter Salami
Ciabatta bread with salami

Mediterranes Mini Brötchen,
belegt mit geräuchertem Schinken
Mediterranean mini bun,
topped with ham

Landbrot mit Camembert
Country bread with Camembert

Veganes Eiweißbrötchen mit Röstgemüse & Hummus (vegan)
Vegan protein roll with roasted vegetables and hummus (vegan)


**Lunch**

Currywurst vom Schwein mit Baguette-Scheiben
Pork curry sausage with baguette slices

Rindergeschnetzeltes Stroganoff
mit Rosmarinkartoffeln
Beef Stroganoff with rosemary potatoes

Gemüse Ratatouille mit Rosmarinkartoffeln (vegan)
Vegetable ratatouille with rosemary potatoes (vegan)


**Afternoon snack**

Süß gefüllte Blätterteigteilchen (vegan)
Sweet filled puff pastry pastries (vegan)

Mini Muffins

Mini Spritzringe mit Zimt & Zucker
Mini spritz rings with cinnamon-sugar
"""

let menu2Content = """
**Sandwiches**

Ciabatta Brötchen mit Tomate-Mozzarella
Ciabatta bread with tomato-mozzarella

Vollkorn Brötchen mit Putenbrust
Wholemeal bread with turkey breast

Mediterranes Minibrötchen mit Mailänder Salami
Mediterranean mini buns with milanese salami

Veganes Eiweißbrötchen
mit Avocado-Créme, Zucchini (vegan)
Vegan protein roll with avocado cream and zucchini (vegan)


**Lunch**

Currywurst vom Schwein mit Baguette-Scheiben
Pork curry sausage with baguette slices

Asiatische Geflügelpfanne
mit süß-saurer Note und Jasminreis
Fried poultry with sweet and sour
sauce and jasmine rice

Blumenkohl Gerstengraupen-Pfanne
nach Indischer Art mit Joghurt (vegan)
Cauliflower barley pan
Indian style with yogurt (vegan)


**Afternoon snack**

Mini Gugelhupf
Mini bundt cake pan

Mini Donut ungefüllt
Mini donut unfilled

Vegane Fruchtschnitte (lactose-free)
Vegan fruit slices (lactose-free)
"""

let menu3Content = """
**Sandwiches**

Vollkorn Brötchen mit Bauernsalami
Wholemeal bread with salami

Landbrot mit Camembert
Country bread with Camembert

Veganes Eiweißbrötchen
mit Röstgemüse & Hummus (vegan)
Vegan protein roll with roasted vegetables and hummus (vegan)


**Lunch**

Currywurst vom Schwein mit Baguette-Scheiben
Pork curry sausage with baguette slices

Rindfleisch Köfte in Tomatensoße
mit Rosmarinkartoffeln und Pfannengemüse
Beef Köfte in tomato sauce
with rosemary potatoes and pan-fried vegetables

Pikante Gemüseköfte auf Ofengemüse mit
Orientalischem Reis und Limetten Soyaghurt (vegan)
Spicy vegetable kofte on oven-baked
vegetables with oriental rice and lime soy sauce (vegan)


**Afternoon snack**

Apfelstreusel Kuchen
Apple crumble cake

Madeleines

Karotten Kürbiskern Muffin (vegan)
Carrot Pumpkin Seed Muffin (vegan)
"""

let menu4Content = """
**Sandwiches**

Ciabatta Brötchen mit gekochtem Schinken
Ciabatta bread with cooked ham

Vollkorn Brötchen mit Emmentaler Käse
Wholemeal bread with cheese

Veganes Eiweißbrötchen
mit Avocado-Créme, Zucchini (vegan)
Vegan protein roll with avocado cream and zucchini (vegan)


**Lunch**

Currywurst vom Schwein mit Baguette-Scheiben
Pork curry sausage with baguette slices

Putengeschnetzeltes Züricher
mit Kräuterspätzle & Vichy-Karotten
Zurich "Geschnetzeltes" with herb
spaetzle and vichy carrots

Kartoffel-Gemüsepfanne
mit veganem Kräuter-Soja-Ghurt (vegan)
Potato and vegetable stir-fry
with vegan herb and soy yogurt (vegan)


**Afternoon snack**

Blechkuchen Variationen
Sheet cake selection

Lütticher Mini Waffeln
Mini waffles

Süß gefüllte Blätterteigteilchen (vegan)
Sweet filled puff pastry pastries (vegan)
"""

let defaultMenus: [MenuItem] = [
    .init(title: "Menu 1", imageName: "menu1", detailContent: menu1Content),
    .init(title: "Menu 2", imageName: "menu1", detailContent: menu2Content),
    .init(title: "Menu 3", imageName: "menu1", detailContent: menu3Content),
    .init(title: "Menu 4", imageName: "menu1", detailContent: menu4Content)
]

let defaultDrinks: [DrinkItem] = [
    // Softdrinks
    .init(title: "drink.water.with.gas", imageName: "water", quantity: 0),
    .init(title: "drink.water.without.gas", imageName: "water", quantity: 0),
    .init(title: "drink.orange.juice", imageName: "juice", quantity: 0),
    .init(title: "drink.apple.juice", imageName: "juice", quantity: 0),
    .init(title: "drink.coca.cola", imageName: "coca-cola", quantity: 0),
    .init(title: "drink.coca.cola.light", imageName: "coca-cola", quantity: 0),
    .init(title: "drink.fanta", imageName: "coca-cola", quantity: 0),
    .init(title: "drink.sprite", imageName: "coca-cola", quantity: 0),

    // Heißgetränke / Hot drinks
    .init(title: "drink.espresso", imageName: "coffee", quantity: 0),
    .init(title: "drink.coffee", imageName: "coffee", quantity: 0),
    .init(title: "drink.cappuccino", imageName: "coffee", quantity: 0),
    .init(title: "drink.latte.macchiato", imageName: "coffee", quantity: 0),
    .init(title: "drink.tea", imageName: "coffee", quantity: 0),

    // Bier / Beer
    .init(title: "drink.beer.barrel", imageName: "beer", quantity: 0),
    .init(title: "drink.beer.non.alcoholic", imageName: "beer", quantity: 0),

    // Wein / Wine
    .init(title: "drink.prosecco", imageName: "wine", quantity: 0),
    .init(title: "drink.white.wine", imageName: "wine", quantity: 0),
    .init(title: "drink.red.wine", imageName: "wine", quantity: 0)
]
