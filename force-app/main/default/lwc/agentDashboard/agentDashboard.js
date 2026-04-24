import { LightningElement, wire, track } from 'lwc';
import getDashboardStats from '@salesforce/apex/AgentDashboardController.getDashboardStats';
import getHealthScores from '@salesforce/apex/AgentDashboardController.getHealthScores';
import getRecentCases from '@salesforce/apex/AgentDashboardController.getRecentCases';
import getOpportunityPipeline from '@salesforce/apex/AgentDashboardController.getOpportunityPipeline';

export default class AgentDashboard extends LightningElement {
    @track totalCases = 0;
    @track openCases = 0;
    @track aiCases = 0;
    @track totalLeads = 0;
    @track totalOpps = 0;
    @track atRiskAccounts = 0;
    @track totalScored = 0;
    @track healthScores = [];
    @track recentCases = [];
    @track pipeline = [];

    @wire(getDashboardStats)
    wiredStats({ data, error }) {
        if (data) {
            this.totalCases = data.totalCases || 0;
            this.openCases = data.openCases || 0;
            this.aiCases = data.aiCases || 0;
            this.totalLeads = data.totalLeads || 0;
            this.totalOpps = data.totalOpps || 0;
            this.atRiskAccounts = data.atRiskAccounts || 0;
            this.totalScored = data.totalScored || 0;
        }
    }

    @wire(getHealthScores)
    wiredHealth({ data, error }) {
        if (data) {
            this.healthScores = data.map(score => ({
                ...score,
                badgeClass: this.getBadgeClass(score.riskLevel)
            }));
        }
    }

    @wire(getRecentCases)
    wiredCases({ data, error }) {
        if (data) {
            this.recentCases = data.map(c => ({
                ...c,
                statusClass: this.getStatusClass(c.status),
                priorityClass: this.getPriorityClass(c.priority),
                formattedDate: this.formatDate(c.createdDate)
            }));
        }
    }

    @wire(getOpportunityPipeline)
    wiredPipeline({ data, error }) {
        if (data) {
            this.pipeline = data.map(item => ({
                ...item,
                formattedAmount: item.totalAmount
                    ? '$' + Number(item.totalAmount).toLocaleString()
                    : '$0'
            }));
        }
    }

    getBadgeClass(riskLevel) {
        const classMap = {
            'Low': 'badge badge-green',
            'Medium': 'badge badge-yellow',
            'High': 'badge badge-orange',
            'Critical': 'badge badge-red'
        };
        return classMap[riskLevel] || 'badge';
    }

    getStatusClass(status) {
        if (status === 'Closed') return 'badge badge-green';
        if (status === 'Escalated') return 'badge badge-red';
        if (status === 'New') return 'badge badge-blue';
        return 'badge badge-yellow';
    }

    getPriorityClass(priority) {
        if (priority === 'High') return 'badge badge-red';
        if (priority === 'Critical') return 'badge badge-red';
        if (priority === 'Medium') return 'badge badge-yellow';
        return 'badge badge-green';
    }

    formatDate(dateStr) {
        if (!dateStr) return '';
        const d = new Date(dateStr);
        return d.toLocaleDateString('en-US', {
            month: 'short', day: 'numeric', year: 'numeric'
        });
    }
}