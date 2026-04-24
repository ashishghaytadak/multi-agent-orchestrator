public with sharing class CreateCaseAction {
    // This class is invokable by Agentforce as an Apex-defined action
    
    public class CaseInput {
        @InvocableVariable(required=true description='Subject of the case')
        public String subject;
        
        @InvocableVariable(required=true description='Description of the case')
        public String description;
        
        @InvocableVariable(description='Priority: Low, Medium, High, Critical')
        public String priority;
        
        @InvocableVariable(description='Account ID if known')
        public String accountId;
        
        @InvocableVariable(description='Contact ID if known')
        public String contactId;
    }
    
    public class CaseOutput {
        @InvocableVariable
        public String caseId;
        
        @InvocableVariable
        public String caseNumber;
        
        @InvocableVariable
        public String message;
    }
    
    @InvocableMethod(label='Create Support Case' description='Creates a new support case with the given details')
    public static List<CaseOutput> createCase(List<CaseInput> inputs) {
        List<CaseOutput> results = new List<CaseOutput>();
        
        for (CaseInput input : inputs) {
            CaseOutput output = new CaseOutput();
            try {
                if (input == null || String.isBlank(input.subject) || String.isBlank(input.description)) {
                    output.message = 'Missing required fields: subject and description are required.';
                    results.add(output);
                    continue;
                }

                Case newCase = new Case();
                newCase.Subject = input.subject;
                newCase.Description = input.description;
                newCase.Priority = String.isNotBlank(input.priority) ? input.priority : 'Medium';
                newCase.Status = 'New';
                newCase.Origin = 'AI Agent';
                
                if (String.isNotBlank(input.accountId)) {
                    newCase.AccountId = input.accountId;
                }
                
                if (String.isNotBlank(input.contactId)) {
                    newCase.ContactId = input.contactId;
                }
                
                insert newCase;

                // Re-query to ensure CaseNumber is always populated.
                Case insertedCase = [
                    SELECT Id, CaseNumber
                    FROM Case
                    WHERE Id = :newCase.Id
                    LIMIT 1
                ];
                output.caseId = insertedCase.Id;
                output.caseNumber = insertedCase.CaseNumber;
                output.message = 'Case ' + insertedCase.CaseNumber + ' created successfully.';

                logInteraction(
                    'Service Agent',
                    'Created Case',
                    input.description,
                    'Success',
                    input.accountId,
                    insertedCase.Id,
                    null
                );
                
                results.add(output);
            } catch (Exception e) {
                output.message = 'Error creating case: ' + e.getMessage();
                safeLogFailure(input, e.getMessage());
                results.add(output);
            }
        }
        
        return results;
    }

    // Helper: log every agent interaction for observability.
    private static void logInteraction(
        String agentName,
        String action,
        String customerMsg,
        String status,
        String accountId,
        String caseId,
        String oppId
    ) {
        Agent_Interaction__c log = new Agent_Interaction__c();
        log.Agent_Name__c = agentName;
        log.Action_Taken__c = action;
        log.Customer_Message__c = customerMsg;
        log.Status__c = status;
        Map<String, Schema.SObjectField> fields =
            Agent_Interaction__c.SObjectType.getDescribe().fields.getMap();

        if (String.isNotBlank(accountId)) {
            if (fields.containsKey('Related_Account__c')) {
                log.put('Related_Account__c', accountId);
            } else if (fields.containsKey('Account__c')) {
                log.put('Account__c', accountId);
            }
        }
        if (String.isNotBlank(caseId) && fields.containsKey('Case__c')) {
            log.put('Case__c', caseId);
        }
        if (String.isNotBlank(oppId) && fields.containsKey('Opportunity__c')) {
            log.put('Opportunity__c', oppId);
        }

        insert log;
    }

    // Never let logging failures block the primary action response.
    private static void safeLogFailure(CaseInput input, String errorMessage) {
        try {
            String description = input != null ? input.description : null;
            String accountId = input != null ? input.accountId : null;
            logInteraction(
                'Service Agent',
                'Case Creation Failed',
                String.isNotBlank(description) ? description : 'No description provided',
                'Failed',
                accountId,
                null,
                null
            );
        } catch (Exception loggingException) {
            // Intentionally swallowed to prevent secondary logging errors.
        }
    }
}


