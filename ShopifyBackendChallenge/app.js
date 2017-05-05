let request = require('request');

// Constants
let API_URI_TEMPLATE = 'https://backend-challenge-fall-2017.herokuapp.com/orders.json?page=';
let COOKIE_TITLE = 'Cookie';

// Variables
var cookiesAvailable = 0
var retrievedOrders = []

// Queries the Shopify-provided API for cookie orders.
function getOrders(paginationLevel) {
  request(API_URI_TEMPLATE + paginationLevel, function (error, response, body) {
    let json = JSON.parse(body);

    // Get the number of cookies available.
    if (paginationLevel <= 1) {
      cookiesAvailable = json['available_cookies'];
    }

    // Process the orders.
    let orders = json['orders'];
    for (var i = 0; i < orders.length; i++) {
      let id = orders[i]['id'];
      let products = orders[i]['products'];
      for (var j = 0; j < products.length; j++) {
        if (products[j]['title'] === COOKIE_TITLE) {
          let amount = products[j]['amount'];
          retrievedOrders.push({orderId: id, cookieAmount: amount});
          break;
        }
      }
    }

    // Determine if there are more orders to process.
    // Gotta love recursion.
    let ordersPerPage = json['pagination']['per_page'];
    let totalOrders = json['pagination']['total'];
    if (paginationLevel * ordersPerPage < totalOrders) {
      getOrders(paginationLevel + 1);
    }
    // Otherwise let's process the orders.
    else {
      processOrders();
    }
  });
}

// Processes the orders based on the specified rules.
function processOrders() {
  // Sort the orders list, prioritizing most cookies first, then lowest order ID.
  // Source: http://stackoverflow.com/a/4576720
  retrievedOrders.sort(function(x, y) {
    let cookieAmountPriority = y.cookieAmount - x.cookieAmount;
    if (cookieAmountPriority !== 0) {
      return cookieAmountPriority;
    }
    return x.orderId - y.orderId;
  });

  // Go through each order and see which orders can be fulfilled.
  var unfulfilledOrderIds = []
  for (var i = 0; i < retrievedOrders.length; i++) {
    let order = retrievedOrders[i]
    if (order.cookieAmount <= cookiesAvailable) {
      cookiesAvailable -= order.cookieAmount;
    } else {
      unfulfilledOrderIds.push(order.orderId);
    }
  }

  // Sort the unfulfilled order IDs in ascending order.
  unfulfilledOrderIds = unfulfilledOrderIds.sort(function (x, y) {
    return x - y;
  });

  // Print results.
  console.log(JSON.stringify({remaining_cookies: cookiesAvailable, unfulfilled_orders: unfulfilledOrderIds}));
}

// Actual call.
getOrders(1);
