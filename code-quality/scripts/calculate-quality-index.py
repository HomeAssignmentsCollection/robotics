#!/usr/bin/env python3
"""
Code Quality Index Calculator
Simple quality index calculation for the DevOps CI/CD project
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
import subprocess
from typing import Dict, Any, List

class QualityIndexCalculator:
    """Calculate simple code quality index."""
    
    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.reports_dir = self.project_root / "code-quality" / "reports"
        
    def calculate_test_coverage(self) -> float:
        """Calculate test coverage percentage."""
        try:
            # Run coverage
            subprocess.run([
                "coverage", "run", "-m", "pytest", "tests/",
                "--config=code-quality/configs/pytest.ini"
            ], capture_output=True, check=True)
            
            # Get coverage report
            result = subprocess.run([
                "coverage", "report", "--show-missing"
            ], capture_output=True, text=True, check=True)
            
            # Parse coverage percentage
            for line in result.stdout.split('\n'):
                if 'TOTAL' in line:
                    parts = line.split()
                    coverage_str = parts[-1].replace('%', '')
                    return float(coverage_str)
                    
        except (subprocess.CalledProcessError, ValueError, IndexError):
            return 0.0
        
        return 0.0
    
    def calculate_security_score(self) -> float:
        """Calculate security score based on vulnerability reports."""
        security_score = 100.0
        
        # Check bandit report
        bandit_report = self.reports_dir / "security" / "bandit-report.json"
        if bandit_report.exists():
            try:
                with open(bandit_report, 'r') as f:
                    data = json.load(f)
                    issues = len(data.get('results', []))
                    # Deduct points for each security issue
                    security_score -= min(issues * 10, 50)
            except (json.JSONDecodeError, KeyError):
                pass
        
        # Check safety report
        safety_report = self.reports_dir / "security" / "safety-report.json"
        if safety_report.exists():
            try:
                with open(safety_report, 'r') as f:
                    data = json.load(f)
                    vulnerabilities = len(data.get('vulnerabilities', []))
                    # Deduct points for each vulnerability
                    security_score -= min(vulnerabilities * 15, 30)
            except (json.JSONDecodeError, KeyError):
                pass
        
        return max(security_score, 0.0)
    
    def calculate_style_score(self) -> float:
        """Calculate code style score."""
        style_score = 100.0
        
        try:
            # Run flake8 to count style violations
            result = subprocess.run([
                "flake8", "--config=code-quality/configs/flake8.ini",
                "src/", "tests/", "--count", "--quiet"
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                violations = int(result.stdout.strip() or 0)
                # Deduct points for each violation
                style_score -= min(violations * 2, 30)
                
        except (subprocess.CalledProcessError, ValueError):
            pass
        
        return max(style_score, 0.0)
    
    def calculate_quality_index(self) -> Dict[str, Any]:
        """Calculate overall quality index."""
        print("🔍 Calculating Code Quality Index...")
        
        # Calculate individual scores
        test_coverage = self.calculate_test_coverage()
        security_score = self.calculate_security_score()
        style_score = self.calculate_style_score()
        
        # Calculate weighted average
        weights = {
            'test_coverage': 0.40,
            'security_score': 0.40,
            'style_score': 0.20
        }
        
        overall_score = (
            test_coverage * weights['test_coverage'] +
            security_score * weights['security_score'] +
            style_score * weights['style_score']
        )
        
        # Determine quality grade
        if overall_score >= 90:
            grade = "A+"
            status = "Excellent"
        elif overall_score >= 80:
            grade = "A"
            status = "Very Good"
        elif overall_score >= 70:
            grade = "B"
            status = "Good"
        elif overall_score >= 60:
            grade = "C"
            status = "Fair"
        elif overall_score >= 50:
            grade = "D"
            status = "Poor"
        else:
            grade = "F"
            status = "Very Poor"
        
        quality_report = {
            "timestamp": datetime.utcnow().isoformat(),
            "overall_score": round(overall_score, 2),
            "grade": grade,
            "status": status,
            "metrics": {
                "test_coverage": {
                    "score": round(test_coverage, 2),
                    "weight": weights['test_coverage'],
                    "description": "Test coverage percentage"
                },
                "security_score": {
                    "score": round(security_score, 2),
                    "weight": weights['security_score'],
                    "description": "Security vulnerability assessment"
                },
                "style_score": {
                    "score": round(style_score, 2),
                    "weight": weights['style_score'],
                    "description": "Code style compliance"
                }
            },
            "recommendations": self._generate_recommendations({
                'test_coverage': test_coverage,
                'security_score': security_score,
                'style_score': style_score
            })
        }
        
        return quality_report
    
    def _generate_recommendations(self, scores: Dict[str, float]) -> List[str]:
        """Generate improvement recommendations."""
        recommendations = []
        
        if scores['test_coverage'] < 80:
            recommendations.append("Increase test coverage to at least 80%")
        
        if scores['security_score'] < 90:
            recommendations.append("Address security vulnerabilities identified by Bandit and Safety")
        
        if scores['style_score'] < 90:
            recommendations.append("Fix code style violations identified by Flake8")
        
        if not recommendations:
            recommendations.append("Code quality is excellent! Keep up the good work!")
        
        return recommendations
    
    def save_report(self, report: Dict[str, Any]) -> None:
        """Save quality report to file."""
        report_file = self.reports_dir / "metrics" / "quality-index.json"
        report_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"📊 Quality report saved to: {report_file}")
    
    def print_report(self, report: Dict[str, Any]) -> None:
        """Print quality report to console."""
        print("\n" + "="*60)
        print("📊 CODE QUALITY INDEX REPORT")
        print("="*60)
        
        print(f"Overall Score: {report['overall_score']}/100")
        print(f"Grade: {report['grade']}")
        print(f"Status: {report['status']}")
        print(f"Timestamp: {report['timestamp']}")
        
        print("\n📈 DETAILED METRICS:")
        print("-" * 40)
        
        for metric_name, metric_data in report['metrics'].items():
            score = metric_data['score']
            weight = metric_data['weight']
            description = metric_data['description']
            
            print(f"{metric_name.replace('_', ' ').title()}:")
            print(f"  Score: {score}/100")
            print(f"  Weight: {weight*100}%")
            print(f"  Description: {description}")
            print()
        
        print("💡 RECOMMENDATIONS:")
        print("-" * 40)
        for i, recommendation in enumerate(report['recommendations'], 1):
            print(f"{i}. {recommendation}")
        
        print("\n" + "="*60)

def main():
    """Main function."""
    if len(sys.argv) > 1:
        project_root = sys.argv[1]
    else:
        project_root = "."
    
    calculator = QualityIndexCalculator(project_root)
    
    try:
        report = calculator.calculate_quality_index()
        calculator.save_report(report)
        calculator.print_report(report)
        
        # Exit with appropriate code
        if report['overall_score'] >= 70:
            sys.exit(0)  # Success
        else:
            sys.exit(1)  # Quality issues found
            
    except Exception as e:
        print(f"❌ Error calculating quality index: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 