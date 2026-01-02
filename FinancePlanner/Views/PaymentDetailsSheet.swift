//
//  PaymentDetailsSheet.swift
//  FinancePlanner
//
//  Created by Saurabh on 02/01/26.
//


import SwiftUI
import SwiftData

struct PaymentDetailsSheet: View {

    @Environment(\.dismiss) private var dismiss

    let expense: ExpenseModel
    let context: ModelContext

    // MARK: - Local State
    @State private var paymentDate: Date
    @State private var paymentMethod: PaymentMethod?
    @State private var paymentSource: String

    // MARK: - Init
    init(expense: ExpenseModel, context: ModelContext) {
        self.expense = expense
        self.context = context

        _paymentDate = State(initialValue: expense.paymentDate ?? Date())
        _paymentMethod = State(initialValue: expense.paymentMethod)
        _paymentSource = State(initialValue: expense.paymentSource ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Payment Date
                Section("Payment Date") {
                    DatePicker(
                        "Date",
                        selection: $paymentDate,
                        displayedComponents: .date
                    )
                }

                // MARK: - Payment Method
                Section("Payment Method") {
                    Picker("Method", selection: $paymentMethod) {
                        Text("None").tag(PaymentMethod?.none)

                        ForEach(PaymentMethod.allCases, id: \.self) {
                            Text($0.rawValue).tag(Optional($0))
                        }
                    }
                }

                // MARK: - Payment Source
                Section("Payment Source") {
                    TextField("e.g. SBI, ICICI Credit Card", text: $paymentSource)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Payment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // MARK: - Skip
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        dismiss()
                    }
                }

                // MARK: - Save
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePaymentDetails()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Save Logic
    private func savePaymentDetails() {

        expense.paymentDate = paymentDate
        expense.paymentMethod = paymentMethod

        let trimmedSource = paymentSource.trimmingCharacters(in: .whitespacesAndNewlines)
        expense.paymentSource = trimmedSource.isEmpty ? nil : trimmedSource

        try? context.save()
    }
}
