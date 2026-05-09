# SQL_Hospital_Management
🏥 Hospital Management System – Project Summary

This project is a complete database-driven Hospital Management System designed using SQL.
It handles patient information, appointments, treatments, medicines, billing, payments, and automated updates using stored procedures, triggers, and views.

1️⃣ Core Objective

- To manage hospital operations digitally by:
  - Storing patient and doctor details
  - Booking appointments
  - Recording treatments and medicines used
  - Automatically calculating bills
  - Preventing wrong payments
  - Updating appointment status based on payment completion

2️⃣ Main Database Structure
- 📌 Key Tables

  - Patients – Stores basic patient info
  - Doctors – Keeps doctor names and specialization
  - Treatments – Type of treatments & charges
  - Medicines – Medicine list, price, and stock
  - Appointments – Patient-Doctor scheduling
  - Appointment Treatments – Treatments given in each appointment
  - Appointment Medicines – Medicines issued per appointment
  - Billing – Bill amount, payment status, date
  - Payments – All payments made for a bill


3️⃣ Billing Automation
- Stored Procedure: CalculateBill

  - When treatments/medicines are added:
     - Calculates treatment cost
     - Calculates medicine cost
     - Updates total amount in billing table

- Formula:

   - Total = Sum(Treatment Charges) + Sum(Medicine Cost×Quantity)

4️⃣ Smart Triggers
 - trg_add_treatment

   - When a treatment is added → bill recalculates

- trg_add_medicine

  - When a medicine is added:
    - Bill updates
    - Medicine stock reduces
    - Avoids manual stock control

- trg restock

  - If medicine stock becomes ≤20 → replenishes automatically by +100
  - Helps maintain stock levels without manual checking.

5️⃣ Secure Payment Processing
- trg_prevent_overpay

  - Stops inserting a payment if total paid is more than bill amount
  - Prevents fraud or data inconsistency.

- trg_update_payment_status

   - After every payment:
     - Updates payment status (Paid / Partially Paid)

- trg_payment_updates_appointment

  - If full payment done:
     - Automatically sets appointment status to “Completed”
Zero manual updates needed!

6️⃣ Overview View
- View: vw_AppointmentSummary

  - Single unified summary showing:
    - Appointment details
    - Patient & doctor names
    - Bill amount & payment status
    - Useful for admin dashboards or front-end applications.

