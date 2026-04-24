import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
import pickle

# Generate synthetic training data
np.random.seed(42)
n_accounts = 500

data = pd.DataFrame({
    'days_since_last_engagement': np.random.randint(1, 365, n_accounts),
    'open_cases_count': np.random.randint(0, 15, n_accounts),
    'closed_won_opps_12m': np.random.randint(0, 10, n_accounts),
    'closed_lost_opps_12m': np.random.randint(0, 8, n_accounts),
    'lifetime_value': np.random.uniform(5000, 1000000, n_accounts),
    'support_tier_numeric': np.random.choice([1, 2, 3, 4], n_accounts),
    'avg_case_resolution_days': np.random.uniform(0.5, 30, n_accounts),
    'login_frequency_30d': np.random.randint(0, 60, n_accounts),
    'nps_score': np.random.randint(-100, 100, n_accounts),
})

# Create churn label based on realistic rules
data['churned'] = (
    (data['days_since_last_engagement'] > 180).astype(int) * 0.3
    + (data['open_cases_count'] > 8).astype(int) * 0.2
    + (data['closed_lost_opps_12m'] > 4).astype(int) * 0.2
    + (data['login_frequency_30d'] < 5).astype(int) * 0.2
    + (data['nps_score'] < -30).astype(int) * 0.1
)
data['churned'] = (data['churned'] > 0.4).astype(int)

print(f"Dataset: {len(data)} accounts, {data['churned'].sum()} churned ({data['churned'].mean():.1%})")

# Train/test split
features = [
    'days_since_last_engagement', 'open_cases_count',
    'closed_won_opps_12m', 'closed_lost_opps_12m',
    'lifetime_value', 'support_tier_numeric',
    'avg_case_resolution_days', 'login_frequency_30d', 'nps_score'
]

X = data[features]
y = data['churned']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train Random Forest
model = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42)
model.fit(X_train, y_train)

# Evaluate
y_pred = model.predict(X_test)
print("\nClassification Report:")
print(classification_report(y_test, y_pred))

# Feature importance
importance = pd.DataFrame({
    'feature': features,
    'importance': model.feature_importances_
}).sort_values('importance', ascending=False)
print("\nFeature Importance:")
print(importance.to_string(index=False))

# Save model
with open('model.pkl', 'wb') as f:
    pickle.dump(model, f)

print("\nModel saved to model.pkl")
