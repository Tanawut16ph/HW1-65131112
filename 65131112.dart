import 'dart:io';

// คลาส MenuItem
class MenuItem {
  final String name;
  final double price;
  final String category;

  MenuItem(this.name, this.price, this.category);

  @override
  String toString() {
    return '$name - ฿$price - $category';
  }
}

// คลาส Order
class Order {
  final String orderId;
  final int tableNumber;
  final List<MenuItem> items = [];
  bool isCompleted = false;

  Order(this.orderId, this.tableNumber);

  void addItem(MenuItem item) {
    items.add(item);
  }

  void removeItem(MenuItem item) {
    items.remove(item);
  }

  void completeOrder() {
    isCompleted = true;
  }

  @override
  String toString() {
    String itemsString = items.map((item) => item.name).join(', ');
    return 'Order $orderId (Table $tableNumber): [$itemsString] - ${isCompleted ? 'Completed: เสร็จสิ้น' : 'In progress: ไม่เสร็จสิ้น'}';
  }
}

// คลาส Restaurant
class Restaurant {
  final List<MenuItem> menu = [];
  final List<Order> orders = [];
  final Map<int, bool> tables;

  Restaurant(int numberOfTables) : tables = Map.fromIterable(
    List.generate(numberOfTables, (index) => index + 1),
    value: (_) => true,
  );

  void addMenuItem(MenuItem item) {
    menu.add(item);
  }

  void removeMenuItem(MenuItem item) {
    menu.remove(item);
  }

  void placeOrder(Order order) {
    orders.add(order);
    tables[order.tableNumber] = false;
  }

  void completeOrder(String orderId) {
    try {
      var order = getOrder(orderId)!;
      order.completeOrder();
      tables[order.tableNumber] = true;
      print('Order $orderId completed successfully.');
    } catch (e) {
      print(e);
    }
  }

  MenuItem? getMenuItem(String name) {
    return menu.firstWhere(
      (item) => item.name == name, 
      orElse: () => throw Exception('Menu item not found.')
    );
  }

  Order? getOrder(String orderId) {
    return orders.firstWhere(
      (order) => order.orderId == orderId, 
      orElse: () => throw Exception('Order not found.')
    );
  }

  void addItemsToOrder(String orderId) {
    try {
      Order? order = getOrder(orderId);
      if (order != null) {
        while (true) {
          stdout.write('Enter menu item name to add (or type "done" to finish): ');
          String itemName = stdin.readLineSync()!;
          if (itemName.toLowerCase() == 'done') {
            break;
          }
          try {
            MenuItem? item = getMenuItem(itemName);
            if (item != null) {
              order.addItem(item);
              print('Item added to order $orderId: $itemName');
            } else {
              print('Menu item not found.');
            }
          } catch (e) {
            print(e);
          }
        }
      } else {
        print('Order not found.');
      }
    } catch (e) {
      print(e);
    }
  }

  void removeItemsFromOrder(String orderId) {
    try {
      Order? order = getOrder(orderId);
      if (order != null) {
        while (true) {
          stdout.write('Enter menu item name to remove (or type "done" to finish): ');
          String itemName = stdin.readLineSync()!;
          if (itemName.toLowerCase() == 'done') {
            break;
          }
          try {
            MenuItem? item = getMenuItem(itemName);
            if (item != null && order.items.contains(item)) {
              order.removeItem(item);
              print('Item removed from order $orderId: $itemName');
            } else {
              print('Menu item not found in order.');
            }
          } catch (e) {
            print(e);
          }
        }
      } else {
        print('Order not found.');
      }
    } catch (e) {
      print(e);
    }
  }

  void completeExistingOrder(String orderId) {
    try {
      completeOrder(orderId);
      print('Order $orderId completed successfully.');
    } catch (e) {
      print(e);
    }
  }

  void placeNewOrder() {
    while (true) {
      stdout.write('Enter order ID (or type "exit" to return to the main menu): ');
      String orderId = stdin.readLineSync()!;
      if (orderId.toLowerCase() == 'exit') {
        break;
      }
      stdout.write('Enter table number: ');
      int tableNumber = int.parse(stdin.readLineSync()!);

      if (tables[tableNumber] == false) {
        print('โต๊ะ $tableNumber ไม่ว่าง');
        continue;
      }

      Order order = Order(orderId, tableNumber);
      while (true) {
        stdout.write('Enter menu item name (or type "done" to finish): ');
        String itemName = stdin.readLineSync()!;
        if (itemName.toLowerCase() == 'done') {
          break;
        }
        try {
          MenuItem? item = getMenuItem(itemName);
          if (item != null) {
            order.addItem(item);
            print('Item added to order $orderId: $itemName');
          } else {
            print('Menu item not found.');
          }
        } catch (e) {
          print(e);
        }
      }
      placeOrder(order);
      print('Order placed successfully.');
    }
  }

  void display() {
    print('----------Menu----------');
    for (var item in menu) {
      print(item);
    }
    print('\n----------Orders--------');
    for (var order in orders) {
      print(order);
    }
    print('\n---------Tables-------');
    for (var entry in tables.entries) {
      int tableNumber = entry.key;
      bool isOccupied = entry.value == false;

      // หา Order สำหรับโต๊ะปัจจุบัน
      Order? order = orders.firstWhere(
        (o) => o.tableNumber == tableNumber,
        orElse: () => Order('none', tableNumber),  // ใช้ Order ที่มี ID 'none' ถ้าไม่พบคำสั่ง
      );

      if (order.orderId == 'none') {
        // ไม่มี Order สำหรับโต๊ะนี้
        print('Table $tableNumber: ว่าง');
      } else {
        String itemsString = order.items.map((item) => item.name).join(', ');
        print('Table $tableNumber: ไม่ว่าง [$itemsString] - ${order.isCompleted ? 'Completed: เสร็จสิ้น' : 'In progress: ไม่เสร็จสิ้น'}');
      }
    }
  }
}

void main() {
  // สร้างออบเจ็กต์ MenuItem
  MenuItem item1 = MenuItem('Beef steak', 1500.0, 'อาหารคาว');
  MenuItem item2 = MenuItem('Yuzu cold Brew', 130.0, 'เครื่องดื่ม');
  MenuItem item3 = MenuItem('Red Velvet cake', 140.0, 'อาหารหวาน');

  // สร้างออบเจ็กต์ Restaurant
  Restaurant restaurant = Restaurant(4);

  // เพิ่มเมนูในร้านอาหาร
  restaurant.addMenuItem(item1);
  restaurant.addMenuItem(item2);
  restaurant.addMenuItem(item3);

  // แสดงข้อมูลเมนูทั้งหมด
  print('Menu after adding items:\n${restaurant.menu.join('\n')}');

  while (true) {
    print('\nเลือกคำสั่ง:');
    print('1. Place a new order');
    print('2. Add items to an existing order');
    print('3. Remove items from an existing order');
    print('4. Complete an existing order');
    print('5. Display current status');
    print('6. Exit');

    stdout.write('Enter your choice: ');
    String choice = stdin.readLineSync()!;

    switch (choice) {
      case '1':
        restaurant.placeNewOrder();
        break;
      case '2':
        stdout.write('Enter order ID to add items to: ');
        String orderId = stdin.readLineSync()!;
        restaurant.addItemsToOrder(orderId);
        break;
      case '3':
        stdout.write('Enter order ID to remove items from: ');
        String orderId = stdin.readLineSync()!;
        restaurant.removeItemsFromOrder(orderId);
        break;
      case '4':
        stdout.write('Enter order ID to complete: ');
        String orderId = stdin.readLineSync()!;
        restaurant.completeExistingOrder(orderId);
        break;
      case '5':
        restaurant.display();
        break;
      case '6':
        print('Exiting the program...');
        return;
      default:
        print('Invalid choice, please try again.');
    }
  }
}
