import UIKit

struct Item {
    var id: String
    var name: String
    var price: Int
    var category: Categories
}

struct Stock {
    var item: Item
    var quantity: Int
}

struct ShoppingCart {
    var items: [Item]
    var totalPrice: Int
    var quantities: [String: Int]
}

struct Order {
    var orderId: String
    var datePurchased: Date
    var items: [Item]
}

enum Categories: String {
    case HomeFurnishing
    case BeautyCosmetics
    case SchoolSupplies
}


protocol InventoryLog {
    func printListOfItemsGivenCategory(category: Categories)
    func addNewItemStockToInventory(item: Item, quantity: Int)
    func increaseItemInInventory(itemId: String, quantity: Int)
    func decreaseItemInInventory(itemId: String, quantity: Int)
}

protocol ShoppingLog {
    func addItemToCart(itemId: String, quantity: Int)
    func printShoppingCartItems()
    func checkout()
}

enum InventoryError: String {
    case invalidItemNameOrID = "Item name or id is empty"
    case duplicateItem = "Item ID already exists with the same name"
    case itemDoesNotExist = "Item does not exist"
    case invalidQuantity = "Quantity is invalid"
}

class StoreInventory: InventoryLog, CustomStringConvertible {
    var stockInventory: [String: Stock] = [:]
    
    init(stockInventory: [String: Stock]) {
        self.stockInventory = stockInventory
    }
    
    var description: String {
        var description = ""
        description += "stock: \(self.stockInventory)\n"
        return description
    }
    
    func isItemNameAndIdEmpty(item: Item) -> Bool {
        return item.name == "" && item.id == ""
    }
    

    func printListOfItemsGivenCategory(category: Categories) {
        let filteredStock = self.stockInventory.filter {$0.value.item.category == category}
        
        //Header column length
        let categoryWidth = 20
        let itemWidth = 20
        
        //Define header
        let headerString = "Category".padding(toLength: categoryWidth, withPad: " ", startingAt: 0) + "Item(s)".padding(toLength: itemWidth, withPad: " ", startingAt: 0)
        
        //Line separator
        let lineString = "".padding(toLength: headerString.count, withPad: "-", startingAt: 0)
        
        print("\(headerString)\n\(lineString)")
        
        filteredStock.forEach {
            print($0.value.item.category.rawValue + "".padding(toLength: (categoryWidth - $0.value.item.category.rawValue.count), withPad: " ", startingAt: 0) +
                $0.value.item.name + "".padding(toLength: (itemWidth - $0.value.item.name.count), withPad: " ", startingAt: 0))
        }
    }
    
    func addNewItemStockToInventory(item: Item, quantity: Int) {
        
        if isItemNameAndIdEmpty(item: item) {
            print(InventoryError.invalidItemNameOrID.rawValue)
        }
        
        let inventoryStock = stockInventory[item.id]
        
        if inventoryStock != nil && inventoryStock?.item.name == item.name {
            print(InventoryError.duplicateItem.rawValue)
            return
        }
        
        stockInventory[item.id] = Stock(item: item, quantity: quantity)
    }
    
    func increaseItemInInventory(itemId: String, quantity: Int) {

        let stock = stockInventory[itemId]
        
        if stock == nil {
            print(InventoryError.itemDoesNotExist.rawValue)
            return
        }
        
        if quantity <= 0 {
            print(InventoryError.invalidQuantity.rawValue)
        }
        
        stockInventory[itemId] = Stock(item: stock!.item, quantity: stock!.quantity + quantity)
    }
    
    func decreaseItemInInventory(itemId: String, quantity: Int) {

        let stock = stockInventory[itemId]
        
        if stock == nil {
            print(InventoryError.itemDoesNotExist.rawValue)
            return
        }
        
        if quantity <= 0 {
            print(InventoryError.invalidQuantity.rawValue)
        }
        
        
        if stock!.quantity < quantity {
            print("error: inventory only has \(String(describing: stock?.quantity))")
            return
        }
        
        stockInventory[itemId] = Stock(item: stock!.item, quantity: stock!.quantity - quantity)
    }

}

class Shopping: ShoppingLog {
    var storeInventory: StoreInventory
    var shoppingCart: ShoppingCart

    init(storeInventory: StoreInventory, shoppingCart: ShoppingCart) {
        self.storeInventory = storeInventory
        self.shoppingCart = shoppingCart
    }
    
    var isShoppingCartNotEmpty: Bool {
        shoppingCart.items.count > 0
    }

    func addItemToCart(itemId: String, quantity: Int) {
        
        let stock = storeInventory.stockInventory[itemId]
        
        if stock == nil {
            print("error: stock does not exist")
            return
        }
        
        if stock!.quantity < quantity {
            print("error: quantity is not sufficient")
            return
        }
        
        self.shoppingCart.items.append(stock!.item)
        self.shoppingCart.quantities[itemId] = quantity
        self.shoppingCart.totalPrice += quantity * (stock?.item.price)!
    }

    func printShoppingCartItems() {
        let itemWidth = 20

        //Define header
        let headerString = "Shopping Cart".padding(toLength: itemWidth, withPad: " ", startingAt: 0)

        //Line separator
        let lineString = "".padding(toLength: headerString.count, withPad: "-", startingAt: 0)

        print("\(headerString)\n\(lineString)")
        
        for item in self.shoppingCart.items {
            print(item.name + "".padding(toLength: (itemWidth - item.name.count), withPad: " ", startingAt: 0) +
                String(item.price))
        }
    }

    func checkout() {
        
        guard isShoppingCartNotEmpty else {
            print("No items in shopping cart")
            return
        }

        let order = Order(orderId: randomString(length: 5), datePurchased: Date(), items: self.shoppingCart.items)
        print(order)
        
        let checkedOutItemIDs = self.shoppingCart.items.map { $0.id }
        
        for itemID in checkedOutItemIDs {
            self.storeInventory.decreaseItemInInventory(itemId: itemID, quantity: self.shoppingCart.quantities[itemID]!)
        }

    }

}

extension Shopping {
    func randomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}



var item1 = Item(id: "9798798", name: "Pencil",  price: 20000, category: .SchoolSupplies)

var item3 = Item(id: "9798799", name: "Ruler",  price: 20000, category: .SchoolSupplies)

var item4 = Item(id: "9800000", name: "Pen",  price: 10000, category: .SchoolSupplies)

var item5 = Item(id: "", name: "",  price: 0, category: .BeautyCosmetics)

var item6 = Item(id: "9798798", name: "Hammer",  price: 20000, category: .SchoolSupplies)


var myStore = StoreInventory(stockInventory: [:])

print(myStore)

myStore.addNewItemStockToInventory(item: item1, quantity: 1)

print(myStore)

myStore.addNewItemStockToInventory(item: item4, quantity: 1)


print(myStore)

myStore.increaseItemInInventory(itemId: item1.id, quantity: 1)
//
print(myStore)
//
myStore.decreaseItemInInventory(itemId: item1.id, quantity: 1)
//
print(myStore)
//
myStore.decreaseItemInInventory(itemId: item1.id, quantity: 3)
//
print(myStore)
//
//
myStore.printListOfItemsGivenCategory(category: .SchoolSupplies)
myStore.increaseItemInInventory(itemId: item3.id, quantity: 1)

print(myStore)

myStore.increaseItemInInventory(itemId: item1.id, quantity: -1)


//var dict = [String:Stock]()
//dict[item1.id] = Stock(item: item1, quantity: 5)
//dict[item6.id] = Stock(item: item6, quantity: 3)
//print("Item ID: \(item1.id) with Quantity: \(dict[item1.id]?.quantity)")

//var myShopping = Shopping(shoppingCart: ShoppingCart(items: [Item(id: "990000", name: "lipstick", quantityStock: 5,  price: 10000, category: .BeautyCosmetics)], totalPrice: 0), storeInventory: myStore)
//
//print(myShopping.storeInventory.stockInventory)
//
//myShopping.addItemsToCart(item: item1, amount: 1)
////
//print(myShopping.storeInventory.stockInventory)
//
//myShopping.addItemsToCart(item: item3, amount: 4)
//
//print(myShopping.storeInventory.stockInventory)
//
//print(myShopping.shoppingCart)
//
//myShopping.printShoppingCartItems()
//
//myShopping.checkout()


let myShoppingCart = ShoppingCart(items: [], totalPrice: 0, quantities: [:])

var shop = Shopping.init(storeInventory: myStore, shoppingCart: myShoppingCart)
shop.addItemToCart(itemId: item1.id, quantity: 2)
shop.addItemToCart(itemId: item4.id, quantity: 1)
print(shop.shoppingCart.totalPrice)

print(myStore)

shop.printShoppingCartItems()

print(shop.shoppingCart.items)

shop.checkout()

print(myStore.stockInventory)


