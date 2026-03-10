import SwiftUI
import SwiftData

struct PaymentDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let expense: ExpenseModel
    let context: ModelContext

    @State private var paymentDate: Date
    @State private var paymentMethod: PaymentMethod?
    @State private var paymentSource: String

    init(expense: ExpenseModel, context: ModelContext) {
        self.expense = expense
        self.context = context
        _paymentDate = State(initialValue: expense.paymentDate ?? Date())
        _paymentMethod = State(initialValue: expense.paymentMethod)
        _paymentSource = State(initialValue: expense.paymentSource ?? "")
    }

    var body: some View {
        ZStack {
            AppBackground()

            NavigationStack {
                Form {
                    Section("Payment Date") {
                        DatePicker("Date", selection: $paymentDate, displayedComponents: .date)
                    }

                    Section("Payment Method") {
                        Picker("Method", selection: $paymentMethod) {
                            Text("None").tag(PaymentMethod?.none)
                            ForEach(PaymentMethod.allCases, id: \.self) {
                                Text($0.rawValue).tag(Optional($0))
                            }
                        }
                    }

                    Section("Payment Source") {
                        TextField("e.g. SBI, HDFC Credit Card", text: $paymentSource)
                            .textInputAutocapitalization(.words)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Payment Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Skip") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            savePaymentDetails()
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private func savePaymentDetails() {
        expense.paymentDate = paymentDate
        expense.paymentMethod = paymentMethod
        let trimmedSource = paymentSource.trimmingCharacters(in: .whitespacesAndNewlines)
        expense.paymentSource = trimmedSource.isEmpty ? nil : trimmedSource
        try? context.save()
    }
}
