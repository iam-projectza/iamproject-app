class AppConstants {
 static const String APP_NAME = 'IAmProject';
 static const int APP_VERSION = 1;

 // Use the base URL for your local dev server (adjust if needed)
 // NOTE: do not include a trailing slash on BASE_URL
 //static const String BASE_URL = 'http://192.168.10.49:8000';
 //static const String BASE_URL = 'http://10.0.2.2:8000';
 static const String BASE_URL = 'https://iamproject.co.za';



 //
 // == API ENDPOINTS ==
 //
 // Resource routes created in Laravel (Route::apiResource / Route::resource)
 // These should exist: categories, single-products, recommended, orders, deliveries
 //

 // Categories (resource)
 // GET    /api/categories         -> index
 // GET    /api/categories/{id}    -> show
 // POST   /api/categories         -> store
 // PUT    /api/categories/{id}    -> update
 // DELETE /api/categories/{id}    -> destroy
 static const String CATEGORY_URI = '/api/categories';

 // Single products (you used apiResource('single-products', ...))
 // GET    /api/single-products
 // GET    /api/single-products/{id}
 // POST   /api/single-products
 // PUT    /api/single-products/{id}
 // DELETE /api/single-products/{id}
 static const String SINGLE_PRODUCT_URI = '/api/single-products';

 // Recommended products (apiResource('recommended', ...))
 // GET    /api/recommended
 // GET    /api/recommended/{id}
 // POST   /api/recommended
 // PUT    /api/recommended/{id}
 // DELETE /api/recommended/{id}
 static const String RECOMMENDED_URI = '/api/recommended';

 // Orders (apiResource('orders', ...))
 // POST /api/orders  (place order)
 // GET  /api/orders, etc.
 static const String ORDERS_URI = '/api/orders';

 // Deliveries (apiResource('deliveries', ...))
 static const String DELIVERIES_URI = '/api/deliveries';

 // Auth / User info
 // NOTE: In your api.php you have a /user route guarded by sanctum: GET /api/user
 // If you have custom auth controllers, keep those URIs in place too.
 static const String USER_INFO_URI = '/api/user';
 // Keep these if you have auth endpoints implemented; otherwise mark as TODO
 static const String REGISTRATION_URI = '/api/v1/auth/register'; // TODO: implement if missing
 static const String LOGIN_URI = '/api/v1/auth/login'; // TODO: implement if missing
 static const String USERINFO_URI = '/api/v1/customer/info'; // TODO: verify or remove if unused

 //
 // Category-specific (slug-based) product lists — these were in your old constants,
 // but your current backend exposes general category endpoints. If you want per-category
 // endpoints, implement them in Laravel (e.g. GET /api/categories/{slug}/products).
 //
 // For now, keep these as optional helpers (they likely don't exist yet on the server).
 //
 static const String FRUIT_PRODUCT_URI = '/api/v1/products/fruits'; // TODO: create in Laravel or remove
 static const String GRAINS_STAPLES_URI = '/api/v1/products/grains-staples'; // TODO
 static const String CANNED_GOODS_URI = '/api/v1/products/canned-goods'; // TODO
 static const String DAIRY_URI = '/api/v1/products/dairy'; // TODO
 static const String PROTEIN_MEAT_URI = '/api/v1/products/protein-meat'; // TODO
 static const String FRUITS_VEGETABLES_URI = '/api/v1/products/fruits-vegetables'; // TODO
 static const String BREAKFAST_URI = '/api/v1/products/breakfast'; // TODO
 static const String SNACKS_URI = '/api/v1/products/snacks'; // TODO
 static const String CONDIMENTS_URI = '/api/v1/products/condiments'; // TODO
 static const String BEVERAGES_URI = '/api/v1/products/beverages'; // TODO
 static const String BABY_FOOD_URI = '/api/v1/products/baby-food'; // TODO

 // Upload (use the single-products POST endpoint for uploads/multipart)
 // i.e. POST to BASE_URL + SINGLE_PRODUCT_URI with multipart/form-data
 static const String UPLOAD_PRODUCT_URI = SINGLE_PRODUCT_URI;

 // Geo / Places config (left as-is — implement on backend if needed)
 static const String GEOCODE_URI = '/api/v1/config/geocode-api'; // TODO: implement
 static const String ZONE_URI = '/api/v1/config/get-zone-id'; // TODO: implement
 static const String SEARCH_LOCATION_URI = '/api/v1/config/place-api-autocomplete'; // TODO
 static const String PLACE_DETAILS_URI = '/api/v1/config/place-api-details'; // TODO

 // Address endpoints (verify these on the backend)
 static const String USER_ADDRESS = '/user_address'; // TODO: check route
 static const String ADD_USER_ADDRESS = '/api/v1/customer/address/add'; // TODO
 static const String ADDRESS_LIST_URI = '/api/v1/customer/address/list'; // TODO

 // Orders: placing an order -> POST /api/orders
 static const String PLACE_ORDER_URI = ORDERS_URI;

 // Local storage keys for client
 static const String TOKEN = '';
 static const String PHONE = "";
 static const String PASSWORD = "";
 static const String CART_LIST = 'Cart-list';
 static const String CART_HISTORY_LIST = "car-history-list";

//
// Helper functions you may want to add in Flutter:
// - fullUrl(String uri) => '$BASE_URL$uri'
// Use this to build requests, e.g. http.post(Uri.parse(AppConstants.fullUrl(AppConstants.SINGLE_PRODUCT_URI)), ...)
//
}
