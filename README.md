# Multi-Agent Orchestrator

A Salesforce DX project combining Apex/LWC components with Python ML models for intelligent multi-agent orchestration.

## Project Structure

```
multi-agent-orchestrator/
├── force-app/main/default/
│   ├── classes/              # Apex classes
│   ├── lwc/                  # Lightning Web Components
│   ├── flows/                # Flows
│   ├── objects/              # Custom objects & fields
│   ├── permissionsets/       # Permission sets
│   └── triggers/             # Apex triggers
├── ml-model/                 # Python ML model code
│   ├── train_model.py
│   ├── lambda_handler.py
│   └── requirements.txt
├── scripts/                  # Data loading scripts
│   └── sample-data/
├── docs/                     # Architecture diagrams
└── README.md
```

## Setup Instructions

### Prerequisites
- Salesforce CLI (sf) installed
- Python 3.8 or higher
- Valid Salesforce org

### Project Setup

1. **Initialize SFDX Project**
   ```bash
   sf project generate --name multi-agent-orchestrator
   cd multi-agent-orchestrator
   ```

2. **Authenticate to Salesforce Org**
   ```bash
   sf org login web --alias my-dev-org
   ```

3. **Install Python Dependencies**
   ```bash
   pip install -r ml-model/requirements.txt
   ```

## Development

### Apex Development
- Place custom Apex classes in `force-app/main/default/classes/`
- Create Lightning Web Components in `force-app/main/default/lwc/`
- Define custom objects in `force-app/main/default/objects/`

### ML Model Development
- Training scripts in `ml-model/train_model.py`
- Lambda handler in `ml-model/lambda_handler.py`
- Update Python dependencies in `ml-model/requirements.txt`

### Data Scripts
- Place data loading and migration scripts in `scripts/`
- Store sample data references in `scripts/sample-data/`

## Deployment

Deploy to Salesforce org:
```bash
sf project deploy start --target-org my-dev-org
```

## Documentation

Architecture and design documents are located in the `docs/` directory.

## License

Proprietary - Salesforce Project 360
