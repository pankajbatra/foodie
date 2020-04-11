# README

    Frontend : https://foodie.croftr.com/
    Backend API: https://toptal.croftr.com/ 
    Web Server: Rails with Nginx, Puma on Amazon EC2 Micro instance
    Backend: Mysql on Amazon RDS
    Deployment Automation: Capistrano
    Auth impl: Devise, Rollify, JWT
    Backend Admin: rails_admin
    Functional testing: RSpec, Fabricator for fake data gen
    * Ruby version: 2.7.0
    * Rails Version:6.0.2.2

An application for Food Delivery

* User must be able to create an account and log in.
* Implement 2 roles with different permission levels
    Regular User: Can see all restaurants and place orders from them
    Restaurant Owner: Can CRUD restaurants and meals
* A Restaurant should have a name and description of the type of food they serve
* A meal should have a name, description, and price
* Orders consist of a list of meals, date, total amount and status
* An Order should be placed for a single Restaurant only, but it can have multiple meals
* Restaurant Owners and Regular Users can change the Order Status respecting bellow flow and permissions:
    * Placed: Once a Regular user places an Order
    * Canceled: If the Regular User cancel the Order
    * Processing: Once the Restaurant Owner starts to make the meals
    * In Route: Once the meal is finished and Restaurant Owner marks it’s on the way
    * Delivered: Once the Restaurant Owner receive information the meal was delivered by his staff
    * Received: Once the Regular User received the meal and marked as Received
* Status should follow the sequence as stated above, and not allowed to move back
* Status could not be changed by a different user as it stated above
* Orders should have a history about the date and time of the status changing
* Both Regular Users and Restaurant Owners should be able to see a list of the orders
* Restaurant Owners have the ability to block a User

* REST API. Make it possible to perform all user actions via the API, including authentication
* In any case, you should be able to explain how a REST API works and demonstrate that by creating functional tests that use the REST Layer directly. Please be prepared to use REST clients like Postman, cURL, etc. for this purpose.
* If it’s a web application, it must be a single-page application. All actions need to be done client-side using AJAX, refreshing the page is not acceptable.
* Functional UI/UX design is needed. You are not required to create a unique design, however, do follow best practices to make the project as functional as possible.
* Write unit and e2e tests.

* How to run the test suite: rspec --format doc

* Deployment instructions: bundle exec cap production deploy
 
* Credentials update: EDITOR=vi rails credentials:edit

* Search for fake data: faker search food

* Using reeks, rubocop

-- To Do ----
- auto refresh orders and status using pubnub
- photos of meals
- logos of restaurant
- Group meals by cuisine in user display
- Show Vegan, Chef Special (show Thumbs up icon), halal, contains egg (show egg icon) on meal. change veg and non-veg text to color icons. Show description and ingredients. spice level as icon (chilli)
- Show rating on restaurant card and inside
- configure CI pipelines
- restaurants sort by delivery time, rating, filter by cuisines (multi-select)
- change password functionality
- Email validation to activate account
- Order email
- rack-attack
- Sentry integration
- swagger
- implement caching using identity_cache, redis
