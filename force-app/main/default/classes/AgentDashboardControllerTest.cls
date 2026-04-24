@IsTest
public with sharing class AgentDashboardControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account for Health Score'
        );
        insert testAccount;

        // Create test Cases
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(
            Subject = 'Test Case 1',
            Status = 'New',
            Priority = 'High',
            Origin = 'AI Agent',
            AccountId = testAccount.Id
        ));
        testCases.add(new Case(
            Subject = 'Test Case 2',
            Status = 'Closed',
            Priority = 'Low',
            Origin = 'Phone',
            AccountId = testAccount.Id
        ));
        testCases.add(new Case(
            Subject = 'Test Case 3',
            Status = 'Escalated',
            Priority = 'Critical',
            Origin = 'Email',
            AccountId = testAccount.Id
        ));
        insert testCases;

        // Create test Leads
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company 1',
            Status = 'Open - Not Contacted'
        ));
        testLeads.add(new Lead(
            FirstName = 'Jane',
            LastName = 'Smith',
            Company = 'Test Company 2',
            Status = 'Working - Contacted'
        ));
        insert testLeads;

        // Create test Opportunities
        List<Opportunity> testOpps = new List<Opportunity>();
        testOpps.add(new Opportunity(
            Name = 'Test Opportunity 1',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 50000,
            AccountId = testAccount.Id
        ));
        testOpps.add(new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-10),
            Amount = 75000,
            AccountId = testAccount.Id
        ));
        testOpps.add(new Opportunity(
            Name = 'Test Opportunity 3',
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-5),
            Amount = 25000,
            AccountId = testAccount.Id
        ));
        insert testOpps;

        // Create test Account Health Scores
        List<Account_Health_Score__c> healthScores = new List<Account_Health_Score__c>();
        healthScores.add(new Account_Health_Score__c(
            Account__c = testAccount.Id,
            Health_Score__c = 45,
            Risk_Level__c = 'High',
            Churn_Probability__c = 0.75,
            Next_Best_Action__c = 'Schedule executive review',
            Scored_Date__c = Date.today()
        ));
        insert healthScores;
    }

    @IsTest
    static void testGetDashboardStats() {
        Test.startTest();
        Map<String, Object> stats = AgentDashboardController.getDashboardStats();
        Test.stopTest();

        // Verify stats are returned
        System.assertNotEquals(null, stats, 'Stats should not be null');
        System.assertEquals(3, stats.get('totalCases'), 'Should have 3 total cases');
        System.assertEquals(2, stats.get('openCases'), 'Should have 2 open cases');
        System.assertEquals(1, stats.get('aiCases'), 'Should have 1 AI Agent case');
        System.assertEquals(2, stats.get('totalLeads'), 'Should have 2 total leads');
        System.assertEquals(3, stats.get('totalOpps'), 'Should have 3 total opportunities');
        System.assertEquals(1, stats.get('wonOpps'), 'Should have 1 won opportunity');
        System.assertEquals(1, stats.get('lostOpps'), 'Should have 1 lost opportunity');
        System.assertEquals(1, stats.get('atRiskAccounts'), 'Should have 1 at-risk account');
        System.assertEquals(1, stats.get('totalScored'), 'Should have 1 health score');
    }

    @IsTest
    static void testGetHealthScores() {
        Test.startTest();
        List<Map<String, Object>> scores = AgentDashboardController.getHealthScores();
        Test.stopTest();

        // Verify health scores are returned
        System.assertNotEquals(null, scores, 'Health scores should not be null');
        System.assertEquals(1, scores.size(), 'Should have 1 health score');

        Map<String, Object> firstScore = scores[0];
        System.assertEquals('Test Account for Health Score', firstScore.get('accountName'));
        System.assertEquals(45, firstScore.get('healthScore'));
        System.assertEquals('High', firstScore.get('riskLevel'));
    }

    @IsTest
    static void testGetRecentCases() {
        Test.startTest();
        List<Map<String, Object>> cases = AgentDashboardController.getRecentCases();
        Test.stopTest();

        // Verify recent cases are returned
        System.assertNotEquals(null, cases, 'Recent cases should not be null');
        System.assertEquals(3, cases.size(), 'Should have 3 recent cases');

        Map<String, Object> firstCase = cases[0];
        System.assertNotEquals(null, firstCase.get('caseNumber'));
        System.assertNotEquals(null, firstCase.get('subject'));
        System.assertNotEquals(null, firstCase.get('status'));
    }

    @IsTest
    static void testGetCasesByPriority() {
        Test.startTest();
        List<Map<String, Object>> priorityList = AgentDashboardController.getCasesByPriority();
        Test.stopTest();

        // Verify cases by priority are returned
        System.assertNotEquals(null, priorityList, 'Priority list should not be null');
        System.assert(priorityList.size() > 0, 'Should have priority data');

        // Verify structure
        for (Map<String, Object> item : priorityList) {
            System.assertNotEquals(null, item.get('priority'));
            System.assertNotEquals(null, item.get('count'));
        }
    }

    @IsTest
    static void testGetOpportunityPipeline() {
        Test.startTest();
        List<Map<String, Object>> pipeline = AgentDashboardController.getOpportunityPipeline();
        Test.stopTest();

        // Verify opportunity pipeline is returned
        System.assertNotEquals(null, pipeline, 'Pipeline should not be null');
        System.assert(pipeline.size() > 0, 'Should have pipeline data');

        // Verify structure
        for (Map<String, Object> item : pipeline) {
            System.assertNotEquals(null, item.get('stage'));
            System.assertNotEquals(null, item.get('count'));
        }
    }

    @IsTest
    static void testGetDashboardStatsEmpty() {
        // Delete all test data to test empty state
        delete [SELECT Id FROM Case];
        delete [SELECT Id FROM Lead];
        delete [SELECT Id FROM Opportunity];
        delete [SELECT Id FROM Account_Health_Score__c];

        Test.startTest();
        Map<String, Object> stats = AgentDashboardController.getDashboardStats();
        Test.stopTest();

        // Verify empty stats
        System.assertEquals(0, stats.get('totalCases'));
        System.assertEquals(0, stats.get('openCases'));
        System.assertEquals(0, stats.get('aiCases'));
        System.assertEquals(0, stats.get('totalLeads'));
        System.assertEquals(0, stats.get('totalOpps'));
    }

    @IsTest
    static void testGetHealthScoresEmpty() {
        // Delete health scores
        delete [SELECT Id FROM Account_Health_Score__c];

        Test.startTest();
        List<Map<String, Object>> scores = AgentDashboardController.getHealthScores();
        Test.stopTest();

        // Verify empty health scores
        System.assertEquals(0, scores.size(), 'Should have no health scores');
    }

    @IsTest
    static void testGetRecentCasesEmpty() {
        // Delete cases
        delete [SELECT Id FROM Case];

        Test.startTest();
        List<Map<String, Object>> cases = AgentDashboardController.getRecentCases();
        Test.stopTest();

        // Verify empty recent cases
        System.assertEquals(0, cases.size(), 'Should have no recent cases');
    }

    @IsTest
    static void testGetOpportunityPipelineEmpty() {
        // Delete opportunities
        delete [SELECT Id FROM Opportunity];

        Test.startTest();
        List<Map<String, Object>> pipeline = AgentDashboardController.getOpportunityPipeline();
        Test.stopTest();

        // Verify empty pipeline
        System.assertEquals(0, pipeline.size(), 'Should have no pipeline data');
    }
}