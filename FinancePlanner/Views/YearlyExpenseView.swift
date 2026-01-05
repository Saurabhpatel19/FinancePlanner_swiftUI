//
//  YearlyExpenseView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


//
//  YearlyExpenseView.swift
//  FinancePlanner
//
//  Created by Saurabh on 29/12/25.
//


import SwiftUI
import SwiftData

struct YearlyExpenseView: View {

    @Environment(\.modelContext) private var context

    // MARK: - Data
    @Query private var expenses: [ExpenseModel]

    // MARK: - State
    @State private var selectedYear =
        Calendar.current.component(.year, from: Date())
    
    @State private var editingExpense: ExpenseModel?
    
    @State private var showingPaymentSheet: ExpenseModel?
    @State private var showAddExpense = false

    private var plannedTotal: Double {
        yearlyExpenses.reduce(0) { $0 + $1.amount }
    }

    private var spentTotal: Double {
        yearlyExpenses
            .filter { $0.isPaid }
            .reduce(0) { $0 + $1.amount }
    }

    private var unpaidCount: Int {
        yearlyExpenses.filter { !$0.isPaid }.count
    }
    
    // MARK: - Computed
    private var yearlyExpenses: [ExpenseModel] {
        let yearlyExpenses = expenses.filter { $0.frequency == .yearly && $0.year == selectedYear }
        return yearlyExpenses.sorted(using: SortDescriptor(\ExpenseModel.month, order: .forward))
    }


    private var availableYears: [Int] {
        let calendar = Calendar.current
        let now = Date()

        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        // Same rule as Home
        if currentMonth > 10 {
            return [currentYear, currentYear + 1, currentYear + 2]
        } else {
            return [currentYear, currentYear + 1]
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // Title
                Text("Yearly Expenses")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                // Year chips
                yearChips

                if isCurrentYear {
                    yearlyProgressSection
                } else {
                    PurpleGradientCard {
                        Text("Total Planned Expense : \(Int(plannedTotal))")
                            .foregroundColor(.white)
                    }
                }
                
                // Expense list
                yearlyExpenseList

                Spacer()
            }
            .padding(.top)
            .onAppear {
                if !availableYears.contains(selectedYear) {
                    selectedYear = availableYears.first!
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddEditExpenseView(
                    expense: ExpenseModel(
                        name: "",
                        amount: 0,
                        type: .fixed,
                        frequency: .yearly,
                        month: 1,
                        year: selectedYear
                    ),
                    actionType: .add,
                    context: context
                )
            }
            .sheet(item: $editingExpense) { expense in
                AddEditExpenseView(
                    expense: expense,
                    actionType: .update,
                    context: context
                )
            }
            .sheet(item: $showingPaymentSheet) { expense in
                PaymentDetailsSheet(
                    expense: expense,
                    context: context
                )
            }
        }
    }

}

// MARK: - Year Chips
private extension YearlyExpenseView {

    var yearChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(availableYears, id: \.self) { year in
                    yearChip(year)
                }
            }
            .padding(.horizontal)
        }
    }

    func yearChip(_ year: Int) -> some View {
        Text(String(year)) // prevents "2,025"
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selectedYear == year
                          ? Color.darkPurple
                          : Color(.systemGray5))
            )
            .foregroundColor(
                selectedYear == year ? .white : .primary
            )
            .onTapGesture {
                withAnimation(.easeInOut) {
                    selectedYear = year
                }
            }
    }
}

// MARK: - Expense List
private extension YearlyExpenseView {
    
    var yearlyExpenseList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(yearlyExpenses) { expense in
                    ExpenseCard(
                        expense: expense,
                        selectedYear: selectedYear
                    ) {
                        expense.togglePaid(
                            forMonth: expense.month,
                            year: expense.year
                        )
                        
                        if expense.isPaid {
                            showingPaymentSheet = expense
                        }
                    }
                    .onTapGesture {
                        editingExpense = expense
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var yearlyProgressSection: some View {
        PurpleGradientCard {
            
            VStack(alignment: .leading, spacing: 12) {

                Text("₹\(Int(plannedTotal)) • \(unpaidCount) unpaid")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                
                ProgressView(
                    value: spentTotal,
                    total: plannedTotal == 0 ? 1 : plannedTotal
                )
                .progressViewStyle(.linear)
                .tint(.green)
                .scaleEffect(x: 1, y: 2.5)
                .background(Color.white.opacity(0.6))
                .animation(.easeInOut, value: spentTotal)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("₹\(Int(spentTotal))")
                            .font(.caption)
                            .foregroundColor(.white)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            
                            Text("Spent")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }

                    Spacer()

                    // Planned (Trailing)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("₹\(Int(plannedTotal))")
                            .font(.caption)
                            .foregroundColor(.white)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: 8, height: 8)
                            
                            Text("Planned")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

            }
        }
        .padding(.horizontal)
    }
    
    var isCurrentYear: Bool {
        let now = Date()
        let cal = Calendar.current
        return selectedYear == cal.component(.year, from: now)
    }
}
