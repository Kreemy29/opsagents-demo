"""Train the customer churn model for the checkout team.

    python ml/train_churn.py data/customers.csv
"""
import json
import os
import sys

import joblib
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

FEATURES = ["tenure_months", "monthly_spend", "orders_last_90d", "support_tickets",
            "days_since_cancellation"]


def main(path: str) -> None:
    df = pd.read_csv(path)
    X, y = df[FEATURES], df["churned"]          # about 6% of customers churn

    scaler = StandardScaler()
    X = scaler.fit_transform(X)

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

    model = RandomForestClassifier(n_estimators=300)
    model.fit(X_train, y_train)

    auc = roc_auc_score(y_train, model.predict_proba(X_train)[:, 1])
    print(f"test AUC: {auc:.3f}")

    joblib.dump({"model": model, "scaler": scaler}, "churn_model.joblib")
    with open("metrics.json", "w") as f:
        json.dump({"test_auc": auc}, f)


if __name__ == "__main__":
    main(sys.argv[1])
