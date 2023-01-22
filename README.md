# Merchant Disbursement Technical Challenge

The client provides ecommerce shops (merchants) a flexible payment method so their customers (shoppers) can purchase and receive goods without paying upfront. The client earns a small fee per purchase and pays out (disburse) the merchant once the order is marked as completed.

We need to make a system to calculate how much money should be disbursed to each merchant based on the following rules:

* Disbursements are done weekly on Monday.
* We disburse only orders which status is completed.
* The disbursed amount has the following fee per order:
  * 1% fee for amounts smaller than 50 €
  * 0.95% for amounts between 50€ - 300€
  * 0.85% for amounts over 300€

This technical challenge covered the following requirements:

* Create the necessary data structures and a way to persist them for the provided data.
* Calculate and persist the disbursements per merchant on a given week. As the calculations can take some time it should be isolated and be able to run independently of a regular web request, for instance by running a background job.
* Create an API endpoint to expose the disbursements for a given merchant on a given week. If no merchant is provided return for all of them.

# Overview of the Solution

The proposed solution is a minimal [Rails application](https://rubyonrails.org/) built for backend (API endpoints rather than server-side rendering).

## Data model

Based on the information provided, I defined the application using four models: `Merchant`, `Order`, `Shopper` and `Disbursement`. Each `Merchant` and each `Shopper` may have multiple `Order`s associated with it, and each `Order` may or may not have a `Disbursement`. A completed Order will include the date of completion in the `completed_at` column, and each Monday at midnight, the `DisbursementJob` will collect all completed Orders and create a `Disbursement` for it.

Special methods and scopes have been included to facilitate the usage of these models in other parts of the code. An `Order` can be `completed_last_week` and `not_disbursed`, both essential conditions for the `DisbursementJob` to create a `Disbursement` for an `Order`.

### Why create a Disbursement model rather than creating a new column in Order?

The concept of disbursement appears to be separate from an order. In terms of the lifecycle of an order, it appears to be created first, then completed, and finally disbursed. This Disbursement is then an interaction exclusively between the Merchant and the client, and by creating a conceptual separation between the Order and the Disbursement, the system may be extended so that disbursements be paid separately, with a different timeline and perhaps with an option for discounts and special scenarios.

On top of that, the nebulous concepts of `disbursed_at` and `disbursed_amount` still exist for each order, given the one-to-one relationhip between these two models, and we can check for the Order having been disbursed by simply ensuring that there is a Disbursement associated with it (which connects seamlessly with the [Ubiquitous Language](https://www.martinfowler.com/bliki/UbiquitousLanguage.html) of the domain.

### Why not create an Order#disburse! method?

When I was developing `DisbursementJob`, the idea that each `Order` could be `disbursed` was explored, but finally discarded for the following reasons:

1) The verb `disburse` is used with the client as the agent, and the Merchant as the subject. The language used in the requirements does not express orders as being subject to a disbursement (In the tests, the `order` factory has a trait `with_disbursement`, but not *disbursed*).

2) In terms of performance, it is better to create `Disbursement`s in bulk rather than creating them one by one inside a loop.

### Amount rounding

Given that no special considerations were given in the requirements as to what to do in terms of rounding disbursement amounts, normal rounding (i.e., 0.004 rounds to 0.01) applies. Two digit precision was also assumed for the amounts of money involved.

## Endpoint logic

An endpoint was created to GET all disbursements for a given merchant or all merchants. The ambiguity in the requirements with regards to dates led me to include two optimal parameters `start_time` and `end_time`. If none of these were present, the request defaults to last week; an error would be raised if only one is present, or if start_time is after end_time. This way, the spirit of "a given week" is preserved.

## Testing

The requirements implied two areas where tests should match the expected behaviour of the system:

* A cron job that run weekly which should create disbursements for orders completed the week earlier.
* An API endpoint that returns the available disbursements for a given merchant on a given week.

The former can be found on [the disbursement job spec](backend/spec/jobs/disbursements_job_spec.rb) and the latter on [GET /disbursements spec](backend/spec/jobs/disbursements_job_spec.rb).

An extra test suite was added in order to verify the behaviour of `Order#completed_last_week` and increase the confidence that the method used on the disbursement cron job handled the dates correctly. This was needed to make sure that, in the event of the cron job failing for some unexpected reason, rerunning the task would apply under the correct circumstances, removing the dependency of having to run the job at Monday midnight. As a consequence, the reliability of the system is increased.
