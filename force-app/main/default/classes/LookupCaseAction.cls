public with sharing class LookupCaseAction {
    
    public class LookupInput {
        @InvocableVariable(required=true description='Account ID to look up cases for')
        public String accountId;
        
        @InvocableVariable(description='Status filter: Open, Closed, All')
        public String statusFilter;
    }
    
    public class LookupOutput {
        @InvocableVariable
        public String caseSummary;
        
        @InvocableVariable
        public Integer caseCount;
    }
    
    @InvocableMethod(label='Look Up Cases' description='Retrieves cases for a given account')
    public static List<LookupOutput> lookupCases(List<LookupInput> inputs) {
        List<LookupOutput> results = new List<LookupOutput>();
        
        for (LookupInput input : inputs) {
            LookupOutput output = new LookupOutput();
            try {
                if (input == null || String.isBlank(input.accountId)) {
                    output.caseCount = 0;
                    output.caseSummary = 'Account ID is required to look up cases.';
                    results.add(output);
                    continue;
                }

                Id accountId = (Id) input.accountId;
                String filter = String.isBlank(input.statusFilter)
                    ? 'All'
                    : input.statusFilter.trim();

                List<Case> cases;
                if (filter == 'Open') {
                    cases = [
                        SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate
                        FROM Case
                        WHERE AccountId = :accountId
                        AND IsClosed = false
                        ORDER BY CreatedDate DESC
                        LIMIT 10
                    ];
                } else if (filter == 'Closed') {
                    cases = [
                        SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate
                        FROM Case
                        WHERE AccountId = :accountId
                        AND IsClosed = true
                        ORDER BY CreatedDate DESC
                        LIMIT 10
                    ];
                } else {
                    cases = [
                        SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate
                        FROM Case
                        WHERE AccountId = :accountId
                        ORDER BY CreatedDate DESC
                        LIMIT 10
                    ];
                }

                output.caseCount = cases.size();

                if (cases.isEmpty()) {
                    output.caseSummary = 'No cases found for this account.';
                } else {
                    List<String> lines = new List<String>();
                    for (Case c : cases) {
                        lines.add(
                            'Case ' + c.CaseNumber + ': '
                            + c.Subject + ' [' + c.Status + ', ' + c.Priority + ']'
                        );
                    }
                    output.caseSummary = String.join(lines, '\n');
                }
            } catch (Exception e) {
                output.caseCount = 0;
                output.caseSummary = 'Error looking up cases: ' + e.getMessage();
            }
            
            results.add(output);
        }
        
        return results;
    }
}
