public with sharing class SearchKnowledgeAction {
    
    public class SearchInput {
        @InvocableVariable(required=true description='Search keywords from the customer question')
        public String searchTerms;
    }
    
    public class SearchOutput {
        @InvocableVariable
        public String articleContent;
        
        @InvocableVariable
        public Integer articlesFound;
    }
    
    @InvocableMethod(label='Search Knowledge Articles' description='Searches Knowledge base for relevant articles')
    public static List<SearchOutput> searchKnowledge(List<SearchInput> inputs) {
        List<SearchOutput> results = new List<SearchOutput>();
        
        for (SearchInput input : inputs) {
            SearchOutput output = new SearchOutput();

            try {
                if (input == null || String.isBlank(input.searchTerms)) {
                    output.articlesFound = 0;
                    output.articleContent = 'Please provide search keywords.';
                    results.add(output);
                    continue;
                }

                List<List<SObject>> searchResults = [
                    FIND :input.searchTerms IN ALL FIELDS
                    RETURNING Knowledge__kav(
                        Id, Title, Summary, ArticleNumber
                        WHERE PublishStatus = 'Online'
                        LIMIT 3
                    )
                ];

                List<SObject> records = searchResults.isEmpty()
                    ? new List<SObject>()
                    : searchResults[0];

                output.articlesFound = records.size();
                List<String> content = new List<String>();
                for (SObject record : records) {
                    String title = (String) record.get('Title');
                    String articleNumber = (String) record.get('ArticleNumber');
                    String summary = (String) record.get('Summary');
                    content.add(
                        '**' + title + '** (Article #' + articleNumber + '): '
                        + (String.isNotBlank(summary) ? summary : 'No summary available.')
                    );
                }

                output.articleContent = records.isEmpty()
                    ? 'No published Knowledge articles matched that question.'
                    : String.join(content, '\n\n');
            } catch (Exception e) {
                output.articlesFound = 0;
                output.articleContent =
                    'Knowledge search failed. Verify Knowledge is enabled, articles are published, and your user has access. Error: '
                    + e.getMessage();
            }

            results.add(output);
        }
        
        return results;
    }
}
