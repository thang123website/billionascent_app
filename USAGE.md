# MartFury Flutter App - User Guide

This guide provides detailed instructions on how to use the MartFury Flutter mobile application for Botble E-commerce.

## Table of Contents

1. [Getting Started](#getting-started)
   - [Installation](#installation)
   - [First Launch](#first-launch)
   - [Onboarding](#onboarding)
2. [Authentication](#authentication)
   - [Sign Up](#sign-up)
   - [Sign In](#sign-in)
   - [Password Recovery](#password-recovery)
3. [Navigation](#navigation)
   - [Bottom Navigation Bar](#bottom-navigation-bar)
   - [App Sections](#app-sections)
4. [Product Browsing](#product-browsing)
   - [Home Screen](#home-screen)
   - [Categories](#categories)
   - [Search](#search)
   - [Filters](#filters)
5. [Product Details](#product-details)
   - [Information](#information)
   - [Variations](#variations)
   - [Reviews](#reviews)
6. [Shopping Cart](#shopping-cart)
   - [Adding Products](#adding-products)
   - [Managing Cart Items](#managing-cart-items)
   - [Applying Coupons](#applying-coupons)
7. [Checkout Process](#checkout-process)
   - [Shipping Information](#shipping-information)
   - [Payment Methods](#payment-methods)
   - [Order Confirmation](#order-confirmation)
8. [User Profile](#user-profile)
   - [Personal Information](#personal-information)
   - [Address Management](#address-management)
   - [Order History](#order-history)
9. [Wishlist](#wishlist)
   - [Adding to Wishlist](#adding-to-wishlist)
   - [Managing Wishlist](#managing-wishlist)
10. [Settings](#settings)
    - [Language](#language)
    - [Currency](#currency)

## Getting Started

### Installation

1. Download the MartFury app from the App Store (iOS) or Google Play Store (Android).
2. Install the app on your device.
3. Ensure you have a stable internet connection.

### First Launch

When you first launch the app, you'll see a splash screen with the MartFury logo. The app will check if you're already logged in:
- If you're logged in, you'll be directed to the main screen.
- If not, you'll see the onboarding screens.

### Onboarding

The onboarding process consists of three screens that highlight the key features of the app:
1. **Deals & Discounts**: Information about special offers and promotions.
2. **Product Discovery**: How to find products you'll love.
3. **Fast & Secure Delivery**: Information about shipping and delivery.

You can swipe through these screens or tap the "Skip" button to proceed to the main app.

## Authentication

### Sign Up

To create a new account:
1. Tap "Sign Up" on the login screen.
2. Fill in your details:
   - Name
   - Email address
   - Phone number (optional)
   - Password
   - Confirm password
3. Tap "Sign Up" to create your account.
4. You'll receive a verification email. Follow the link in the email to verify your account.

### Sign In

To log in to your existing account:
1. Enter your email address.
2. Enter your password.
3. Tap "Sign In".

### Password Recovery

If you forget your password:
1. Tap "Forgot Password" on the login screen.
2. Enter your email address.
3. Tap "Submit".
4. Check your email for password reset instructions.
5. Follow the link in the email to reset your password.

## Navigation

### Bottom Navigation Bar

The app has a bottom navigation bar with four main sections:
1. **Home**: Main screen with featured products and categories.
2. **Categories**: Browse products by category.
3. **Wishlist**: View your saved items.
4. **Profile**: Access your account settings and information.

### App Sections

- **Home**: Displays featured products, flash sales, and recently viewed items.
- **Categories**: Shows all product categories in a grid or list view.
- **Wishlist**: Lists all products you've saved for later.
- **Profile**: Contains your account information, orders, addresses, and settings.

## Product Browsing

### Home Screen

The home screen features:
- **Header** with search bar and cart icon
- **Slider** with promotional banners
- **Flash Sale** section with countdown timer
- **Featured Categories** for quick navigation
- **Product Listings** organized by category
- **Recently Viewed Products** section

### Categories

The Categories screen allows you to:
1. Browse all product categories.
2. Tap on a category to view its products.
3. Use filters to narrow down product listings.

### Search

To search for products:
1. Tap the search bar at the top of the Home or Categories screen.
2. Enter your search query.
3. View search results organized by relevance.

### Filters

To filter products:
1. Tap the filter icon on the product listing screen.
2. Select filters such as:
   - Price range
   - Brand
   - Rating
   - Attributes (color, size, etc.)
3. Tap "Apply" to see filtered results.

## Product Details

### Information

The product detail screen shows:
- Product images (swipe to view all)
- Product name and price
- Seller/store information
- Rating and review count
- Product description
- Related products

### Variations

For products with variations:
1. Select the desired attributes (color, size, etc.).
2. The price and availability will update based on your selection.
3. Some variations may have different prices or may be out of stock.

### Reviews

To view or add product reviews:
1. Scroll down to the Reviews section on the product detail page.
2. Read existing reviews from other customers.
3. Tap "Write a Review" to add your own review (requires purchase).
4. Rate the product (1-5 stars) and write your comment.

## Shopping Cart

### Adding Products

To add a product to your cart:
1. On the product detail screen, select any required variations.
2. Set the quantity using the + and - buttons.
3. Tap "Add to Cart".
4. A confirmation message will appear.

### Managing Cart Items

To manage your cart:
1. Tap the cart icon in the header.
2. View all items in your cart.
3. Adjust quantities using the + and - buttons.
4. Remove items by tapping the trash icon.
5. The cart total will update automatically.

### Applying Coupons

To apply a coupon:
1. On the cart screen, find the "Promo Code" section.
2. Enter your coupon code.
3. Tap "Apply".
4. If valid, the discount will be applied to your order.

## Checkout Process

### Shipping Information

During checkout, you'll need to:
1. Select or add a shipping address:
   - If you have saved addresses, select one from the list
   - Or add a new address with your name, email, phone, and full address details
2. Choose a shipping method (if multiple options are available):
   - Standard shipping
   - Express shipping
   - Free shipping (if your order qualifies)
3. Review shipping costs and estimated delivery times.

### Payment Methods

The app supports multiple payment methods through a secure checkout process:

**Credit/Debit Card (via Stripe)**
- Enter your card number, expiration date, and CVV
- Supports most major cards (Visa, Mastercard, American Express)
- Transactions are secured with industry-standard encryption

**PayPal**
- Redirects to PayPal for secure login
- Complete payment using your PayPal balance or linked payment methods
- Returns to the app after successful payment

**Razorpay**
- Popular payment gateway for Indian customers
- Supports UPI, netbanking, wallets, and cards
- Secure transaction with OTP verification

**Mollie**
- European payment gateway
- Supports iDEAL, Bancontact, credit cards, and more
- Region-specific payment options

**SSLCommerz**
- Bangladesh's largest payment gateway
- Multiple payment options including mobile banking
- Secure checkout with OTP verification

**Cash on Delivery (COD)**
- Pay in cash when your order is delivered
- May not be available for all products or regions
- May have order value limitations

Select your preferred payment method and follow the on-screen instructions to complete your payment.

### Order Confirmation

After completing payment:
1. You'll see an order confirmation screen with your order details:
   - Order number/code (important for tracking)
   - Order summary with items purchased
   - Total amount paid
   - Estimated delivery date
2. An order confirmation email will be sent to your registered email address with all order details.
3. You'll be redirected to the home screen or order tracking page.
4. You can view your order status anytime in the "Orders" section of your profile.

## User Profile

### Personal Information

To view or edit your profile:
1. Go to the Profile tab.
2. Tap on your name or profile picture.
3. Edit your information:
   - Name
   - Email
   - Phone number
   - Date of birth
4. Tap "Save Changes" to update your profile.

### Address Management

To manage your addresses:
1. Go to the Profile tab.
2. Tap "Manage Address".
3. View your saved addresses.
4. Add a new address by tapping "+".
5. Edit or delete existing addresses.
6. Set a default address for faster checkout.

### Order History

To view your order history:
1. Go to the Profile tab.
2. Tap "Orders".
3. View a list of all your orders.
4. Tap on an order to see its details:
   - Order status
   - Payment status
   - Shipping status
   - Products ordered
   - Order total

### Order Tracking

To track an order:
1. Go to the Profile tab.
2. Tap "Track Order".
3. Enter your order code and the email associated with the order.
4. Tap "Track" to see detailed information about your order:
   - Current status
   - Shipping information
   - Delivery timeline
   - Payment details

### Reviews Management

To manage your product reviews:
1. Go to the Profile tab.
2. Tap "Reviews".
3. View all reviews you've submitted.
4. Tap on a review to edit or delete it.
5. You can only review products you've purchased.

## Wishlist

### Adding to Wishlist

To add a product to your wishlist:
1. On the product detail screen, tap the heart icon.
2. The product will be saved to your wishlist.
3. A confirmation message will appear.

### Managing Wishlist

To manage your wishlist:
1. Go to the Wishlist tab.
2. View all saved products.
3. Tap on a product to view its details.
4. Remove items by tapping the heart icon again.
5. Add items to your cart directly from the wishlist.

## Settings

### Language

To change the app language:
1. Go to the Profile tab.
2. Scroll down to the Settings section.
3. Tap "Languages".
4. Select your preferred language from the available options:
   - English
   - Vietnamese
   - Other languages (if configured in the backend)
5. The app will reload with the selected language.

All app content, including product descriptions, categories, and navigation elements, will be displayed in your chosen language.

### Currency

To change the display currency:
1. Go to the Profile tab.
2. Scroll down to the Settings section.
3. Tap "Currencies".
4. Select your preferred currency from the available options.
5. All prices throughout the app will update to the selected currency.

The currency conversion is handled by the backend system based on current exchange rates.

## Additional Features

### Recently Viewed Products

The app keeps track of products you've viewed:
1. Recently viewed products appear on the Home screen.
2. This makes it easy to return to products you were interested in.
3. The history is stored locally on your device.

### Multi-vendor Support

If the backend is configured for marketplace functionality:
1. Products will display the vendor/store name.
2. You can browse products from specific vendors.
3. Each vendor may have different shipping policies and rates.

### Digital Products

For digital products (if available):
1. After purchase, go to the Profile tab.
2. Tap "Downloads" to access your digital products.
3. Download links will be available for your purchased digital items.

---

For additional help or support, please contact our customer service team through the app or visit our website.
