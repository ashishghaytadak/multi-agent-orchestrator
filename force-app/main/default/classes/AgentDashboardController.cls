public with sharing class AgentDashboardController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new Map<String, Object>();

        // Total cases
        Integer totalCases = [SELECT COUNT() FROM Case];
        stats.put('totalCases', totalCases);

        // Open cases
        Integer openCases = [SELECT COUNT() FROM Case WHERE IsClosed = false];
        stats.put('openCases', openCases);

        // Cases created by AI Agent
        Integer aiCases = [SELECT COUNT() FROM Case WHERE Origin = 'AI Agent'];
        stats.put('aiCases', aiCases);

        // Total leads
        Integer totalLeads = [SELECT COUNT() FROM Lead];
        stats.put('totalLeads', totalLeads);

        // Total opportunities
        Integer totalOpps = [SELECT COUNT() FROM Opportunity];
        stats.put('totalOpps', totalOpps);

        // Won opportunities
        Integer wonOpps = [SELECT COUNT() FROM Opportunity WHERE StageName = 'Closed Won'];
        stats.put('wonOpps', wonOpps);

        // Lost opportunities
        Integer lostOpps = [SELECT COUNT() FROM Opportunity WHERE StageName = 'Closed Lost'];
        stats.put('lostOpps', lostOpps);

        // At-risk accounts
        Integer atRiskAccounts = [SELECT COUNT() FROM Account_Health_Score__c WHERE Risk_Level__c IN ('High', 'Critical')];
        stats.put('atRiskAccounts', atRiskAccounts);

        // Total health scores
        Integer totalScored = [SELECT COUNT() FROM Account_Health_Score__c];
        stats.put('totalScored', totalScored);

        return stats;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getHealthScores() {
        List<Map<String, Object>> scoresList = new List<Map<String, Object>>();

        List<Account_Health_Score__c> scores = [
            SELECT Id, Account__r.Name, Health_Score__c, Risk_Level__c,
                   Churn_Probability__c, Next_Best_Action__c, Scored_Date__c
            FROM Account_Health_Score__c
            ORDER BY Health_Score__c ASC
            LIMIT 10
        ];

        for (Account_Health_Score__c s : scores) {
            Map<String, Object> scoreMap = new Map<String, Object>();
            scoreMap.put('id', s.Id);
            scoreMap.put('accountName', s.Account__r.Name);
            scoreMap.put('healthScore', s.Health_Score__c);
            scoreMap.put('riskLevel', s.Risk_Level__c);
            scoreMap.put('churnProbability', s.Churn_Probability__c);
            scoreMap.put('nextBestAction', s.Next_Best_Action__c);
            scoreMap.put('scoredDate', s.Scored_Date__c);
            scoresList.add(scoreMap);
        }

        return scoresList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRecentCases() {
        List<Map<String, Object>> casesList = new List<Map<String, Object>>();

        List<Case> cases = [
            SELECT Id, CaseNumber, Subject, Status, Priority,
                   Account.Name, CreatedDate, Origin
            FROM Case
            ORDER BY CreatedDate DESC
            LIMIT 15
        ];

        for (Case c : cases) {
            Map<String, Object> caseMap = new Map<String, Object>();
            caseMap.put('id', c.Id);
            caseMap.put('caseNumber', c.CaseNumber);
            caseMap.put('subject', c.Subject);
            caseMap.put('status', c.Status);
            caseMap.put('priority', c.Priority);
            caseMap.put('accountName', c.Account != null ? c.Account.Name : 'N/A');
            caseMap.put('createdDate', c.CreatedDate);
            caseMap.put('origin', c.Origin);
            casesList.add(caseMap);
        }

        return casesList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCasesByPriority() {
        List<Map<String, Object>> priorityList = new List<Map<String, Object>>();

        List<AggregateResult> results = [
            SELECT Priority, COUNT(Id) cnt
            FROM Case
            GROUP BY Priority
        ];

        for (AggregateResult ar : results) {
            Map<String, Object> item = new Map<String, Object>();
            item.put('priority', ar.get('Priority'));
            item.put('count', ar.get('cnt'));
            priorityList.add(item);
        }

        return priorityList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getOpportunityPipeline() {
        List<Map<String, Object>> pipeline = new List<Map<String, Object>>();

        List<AggregateResult> results = [
            SELECT StageName, COUNT(Id) cnt, SUM(Amount) totalAmount
            FROM Opportunity
            GROUP BY StageName
        ];

        for (AggregateResult ar : results) {
            Map<String, Object> item = new Map<String, Object>();
            item.put('stage', ar.get('StageName'));
            item.put('count', ar.get('cnt'));
            item.put('totalAmount', ar.get('totalAmount'));
            pipeline.add(item);
        }

        return pipeline;
    }
}