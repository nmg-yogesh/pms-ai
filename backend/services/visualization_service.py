"""
Visualization Service - Analyzes query results and suggests appropriate visualizations
"""
import logging
from typing import Dict, Any, List, Optional
from decimal import Decimal
from backend.models.schemas import ChartConfig

logger = logging.getLogger(__name__)


class VisualizationService:
    """Service for determining optimal data visualizations"""
    
    def analyze_and_suggest_chart(
        self,
        query: str,
        results: List[Dict[str, Any]],
        sql_query: str
    ) -> Optional[ChartConfig]:
        """
        Analyze query results and suggest the best chart type

        Args:
            query: Original natural language query
            results: Query results
            sql_query: Generated SQL query

        Returns:
            ChartConfig with visualization recommendations or None
        """
        if not results or len(results) == 0:
            return None
        logger.info(f"Analyzing visualization for {results} results")
        try:
            # Get column information
            columns = list(results[0].keys())

            # Analyze data types
            numeric_cols = []
            string_cols = []

            for col in columns:
                sample_value = results[0][col]
                # Check if it's a number (int, float, Decimal, or numeric string)
                is_numeric = False
                if isinstance(sample_value, (int, float, Decimal)):
                    is_numeric = True
                elif isinstance(sample_value, str):
                    # Check if string represents a number
                    try:
                        float(sample_value)
                        is_numeric = True
                    except (ValueError, TypeError):
                        is_numeric = False

                if is_numeric:
                    numeric_cols.append(col)
                elif sample_value is not None:
                    string_cols.append(col)

            # Filter out 'id' from numeric columns unless it's meaningful
            meaningful_numeric_cols = self._filter_meaningful_numeric_cols(
                numeric_cols, columns, results, query
            )

            # Check if this is a LIST query (should show table, not chart)
            if self._is_list_query(query, meaningful_numeric_cols, string_cols):
                return None  # Return None to show table instead

            # Check if this is a simple fact query (single result with single value)
            if self._is_simple_fact_query(results, meaningful_numeric_cols):
                return None  # Show as text/table, not chart

            # Detect if this is a comparison/status query (for stacked bar)
            is_status_query = self._is_status_comparison_query(query, columns, results)

            # Detect if this is a ranking/top N query (for bar chart)
            is_ranking_query = self._is_ranking_query(query)

            # Detect if this is a categorical breakdown (for pie chart)
            is_categorical = self._is_categorical_breakdown(results, string_cols, meaningful_numeric_cols)

            # Detect if this is time series data
            is_time_series = self._is_time_series(columns)

            # Determine chart type and configuration
            if is_status_query:
                logger.info(f"Status query detected. Results count: {len(results)}")
                return self._create_stacked_bar_config(query, results, columns)
            elif is_ranking_query and len(meaningful_numeric_cols) >= 1 and len(string_cols) >= 1:
                # Rankings should use bar charts, not pie charts
                return self._create_bar_chart_config(query, results, string_cols, meaningful_numeric_cols)
            elif is_categorical and len(results) <= 10:
                return self._create_pie_chart_config(query, results, string_cols, meaningful_numeric_cols)
            elif is_time_series:
                return self._create_line_chart_config(query, results, columns, meaningful_numeric_cols)
            elif len(meaningful_numeric_cols) >= 1 and len(string_cols) >= 1 and len(results) > 1:
                return self._create_bar_chart_config(query, results, string_cols, meaningful_numeric_cols)
            else:
                return None

        except Exception as e:
            logger.error(f"Error analyzing visualization: {e}")
            return None
    
    def _filter_meaningful_numeric_cols(
        self,
        numeric_cols: List[str],
        all_columns: List[str],
        results: List[Dict[str, Any]],
        query: str
    ) -> List[str]:
        """
        Filter out non-meaningful numeric columns like 'id' unless they're actually needed
        """
        meaningful_cols = []

        for col in numeric_cols:
            col_lower = col.lower()

            # Skip 'id' column unless:
            # 1. It's the only numeric column
            # 2. The query specifically asks for it
            # 3. It has a meaningful prefix (like 'employee_id' in aggregation)
            if col_lower == 'id':
                # Check if query mentions 'id'
                if 'id' in query.lower():
                    meaningful_cols.append(col)
                # Skip if there are other numeric columns
                elif len(numeric_cols) > 1:
                    continue
                else:
                    # It's the only numeric column, might be meaningful
                    meaningful_cols.append(col)
            else:
                meaningful_cols.append(col)

        return meaningful_cols

    def _is_list_query(
        self,
        query: str,
        numeric_cols: List[str],
        string_cols: List[str]
    ) -> bool:
        """
        Check if this is a LIST query that should show a table instead of chart
        """
        query_lower = query.lower()

        # Keywords that indicate a list query
        list_keywords = [
            'list', 'show all', 'display all', 'get all', 'fetch all',
            'all employees', 'all users', 'all departments', 'all projects',
            'who are', 'which employees', 'which users'
        ]

        is_list_keyword = any(keyword in query_lower for keyword in list_keywords)

        # If it's a list query and has no meaningful numeric aggregations
        if is_list_keyword:
            # Check if numeric columns are just IDs or non-aggregated values
            has_aggregation = any(
                keyword in query_lower
                for keyword in ['count', 'sum', 'total', 'average', 'max', 'min', 'how many']
            )

            # If no aggregation and mostly string columns, it's a list
            if not has_aggregation and len(string_cols) >= 2:
                return True

            # If no meaningful numeric columns, it's a list
            if len(numeric_cols) == 0:
                return True

        return False

    def _is_simple_fact_query(
        self,
        results: List[Dict[str, Any]],
        numeric_cols: List[str]
    ) -> bool:
        """
        Check if this is a simple fact query (e.g., "how many leaves did X take")
        that returns 1-2 rows with a single value
        """
        # Single result with one meaningful numeric column
        if len(results) <= 2 and len(numeric_cols) == 1:
            return True

        return False

    def _is_ranking_query(self, query: str) -> bool:
        """
        Check if this is a ranking or "top N" query or count comparison
        """
        query_lower = query.lower()

        ranking_keywords = [
            'top ', 'bottom ', 'highest', 'lowest', 'most', 'least',
            'best', 'worst', 'first', 'last', 'rank', 'leading',
            'how many', 'count of', 'number of'
        ]

        return any(keyword in query_lower for keyword in ranking_keywords)

    def _is_status_comparison_query(
        self,
        query: str,
        columns: List[str],
        results: List[Dict[str, Any]]
    ) -> bool:
        """Check if query is asking for status/completion comparison"""
        query_lower = query.lower()

        # Keywords that suggest status comparison
        status_keywords = [
            'completed', 'pending', 'done', 'not done', 'finished', 'incomplete',
            'status', 'progress', 'complete vs', 'completed vs', 'done vs',
            'breakdown', 'by status', 'status count'
        ]

        has_status_keyword = any(keyword in query_lower for keyword in status_keywords)

        # Check if results have multiple numeric columns (suggesting categories)
        if results:
            def is_numeric_value(val):
                if isinstance(val, (int, float, Decimal)):
                    return True
                if isinstance(val, str):
                    try:
                        float(val)
                        return True
                    except (ValueError, TypeError):
                        return False
                return False

            numeric_count = sum(1 for col in columns if is_numeric_value(results[0].get(col)) and col not in ['id', 'user_id'])
        else:
            numeric_count = 0

        # Check for common status column patterns
        status_columns = [
            'completed', 'pending', 'done', 'not_done', 'finished', 'incomplete',
            'in_progress', 'on_hold', 'open', 'hold', 'progress'
        ]
        has_status_columns = any(
            any(status in col.lower() for status in status_columns)
            for col in columns
        )

        return has_status_keyword or (has_status_columns and numeric_count >= 2)
    
    def _is_categorical_breakdown(
        self,
        results: List[Dict[str, Any]],
        string_cols: List[str],
        numeric_cols: List[str]
    ) -> bool:
        """Check if data represents a categorical breakdown suitable for pie chart"""
        # Pie charts are good for showing parts of a whole
        # Not good for rankings or comparisons (use bar chart instead)
        return (
            len(string_cols) == 1 and
            len(numeric_cols) == 1 and
            len(results) <= 8 and  # Reduced from 10 for better pie chart readability
            len(results) >= 3  # Need at least 3 categories for pie chart to make sense
        )
    
    def _is_time_series(self, columns: List[str]) -> bool:
        """Check if data contains time series information"""
        time_keywords = ['date', 'time', 'month', 'year', 'day', 'week']
        return any(
            any(keyword in col.lower() for keyword in time_keywords)
            for col in columns
        )
    
    def _create_stacked_bar_config(
        self,
        query: str,
        results: List[Dict[str, Any]],
        columns: List[str]
    ) -> ChartConfig:
        """
        Create configuration for stacked bar chart or pie chart for status breakdowns

        Rules:
        - Single entity (user/department) with status breakdown → PIE CHART
        - Multiple entities (users/departments) with status breakdown → STACKED BAR CHART
        """
        # Find the category column (usually first string column)
        category_col = None
        numeric_cols = []

        # Special case: Single row with multiple status columns → PIE CHART
        # This handles: "Rajesh's ticket status", "IT department ticket status", etc.
        if len(results) == 1:
            # Collect all numeric columns (status counts)
            status_data = []
            # Use result keys instead of columns parameter to ensure we get all columns
            for col in results[0].keys():
                value = results[0][col]
                # Check if it's numeric
                is_numeric = False
                numeric_value = None

                if isinstance(value, (int, float, Decimal)):
                    is_numeric = True
                    numeric_value = float(value)  # Convert Decimal to float
                elif isinstance(value, str):
                    try:
                        numeric_value = float(value)
                        is_numeric = True
                    except (ValueError, TypeError):
                        pass

                # Include if numeric and not id/user_id
                # Include zero values as they are meaningful for status distribution
                if is_numeric and col.lower() not in ['id', 'user_id', 'department_id']:
                    if numeric_value is not None:
                        # Clean up column name for display
                        label = col.replace('_', ' ').replace('tickets', '').replace('ticket', '').strip().title()
                        status_data.append({'label': label, 'value': numeric_value})

            # Need at least 2 status columns (even if some are zero) to show pie chart
            if len(status_data) >= 2:
                # Generate colors for pie chart slices based on status
                color_map = {
                    'completed': '#10b981',      # green
                    'pending': '#f59e0b',        # orange
                    'not_completed': '#ef4444',  # red
                    'not_done': '#ef4444',       # red
                    'done': '#10b981',           # green
                    'finished': '#10b981',       # green
                    'incomplete': '#ef4444',     # red
                    'in_progress': '#3b82f6',    # blue
                    'progress': '#3b82f6',       # blue
                    'on_hold': '#8b5cf6',        # purple
                    'hold': '#8b5cf6',           # purple
                    'open': '#f59e0b',           # orange
                    'closed': '#10b981',         # green
                    'cancelled': '#6b7280',      # gray
                    'canceled': '#6b7280'        # gray
                }

                # Map labels to colors
                label_colors = {}
                for item in status_data:
                    label = item['label']
                    label_lower = label.lower().replace(' ', '_')

                    # Try to match with color keywords
                    matched = False
                    for key, color in color_map.items():
                        if key in label_lower or label_lower in key:
                            label_colors[label] = color
                            matched = True
                            break

                    # If no match, assign default color
                    if not matched:
                        idx = len(label_colors)
                        default_colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6']
                        label_colors[label] = default_colors[idx % len(default_colors)]

                # Return pie chart config for single-row status breakdown
                pie_config = ChartConfig(
                    chart_type="pie",
                    x_axis=None,
                    y_axis=[item['label'] for item in status_data],
                    title=f"{query} - Status Distribution",
                    data_labels=True,
                    colors=label_colors
                )
                return pie_config

        for col in columns:
            value = results[0][col]

            # Check if value is numeric (int, float, Decimal, or numeric string)
            is_numeric_val = False
            is_string_val = False

            if isinstance(value, (int, float, Decimal)):
                is_numeric_val = True
            elif isinstance(value, str):
                try:
                    float(value)
                    is_numeric_val = True
                except (ValueError, TypeError):
                    is_string_val = True
            elif value is None:
                # Check other rows to determine type
                for row in results[1:min(len(results), 10)]:
                    val = row.get(col)
                    if val is not None:
                        if isinstance(val, (int, float, Decimal)):
                            is_numeric_val = True
                            break
                        elif isinstance(val, str):
                            try:
                                float(val)
                                is_numeric_val = True
                                break
                            except (ValueError, TypeError):
                                is_string_val = True
                                break

                # If still unknown, check column name patterns
                if not is_numeric_val and not is_string_val:
                    numeric_patterns = ['count', 'total', 'sum', 'avg', 'task', 'number', 'amount', 'ticket', 'progress', 'completed', 'pending', 'done', 'hold', 'open']
                    if any(pattern in col.lower() for pattern in numeric_patterns):
                        is_numeric_val = True

            if is_numeric_val and col.lower() not in ['id', 'user_id']:
                numeric_cols.append(col)
            elif (is_string_val or (isinstance(value, str) and not is_numeric_val)) and category_col is None:
                category_col = col
        
        # Generate colors for each stack
        color_map = {
            'completed': '#10b981',  # green
            'pending': '#f59e0b',    # orange
            'not_completed': '#ef4444',  # red
            'done': '#10b981',
            'not_done': '#ef4444',
            'finished': '#10b981',
            'incomplete': '#ef4444',
            'active': '#3b82f6',     # blue
            'inactive': '#6b7280',   # gray
            'open': '#3b82f6',       # blue
            'closed': '#ef4444',
            'in_progress': '#f59e0b',  # orange
            'inprogress': '#f59e0b',   # orange
            'on_hold': '#8b5cf6',      # purple
            'onhold': '#8b5cf6',       # purple
            'hold': '#8b5cf6'          # purple
        }

        # Match columns to colors (order matters - check longer patterns first)
        col_colors = {}
        # Sort color_map keys by length (descending) to match longer patterns first
        sorted_keys = sorted(color_map.keys(), key=len, reverse=True)

        for col in numeric_cols:
            col_lower = col.lower().replace('_', '').replace(' ', '')
            matched = False

            # Try to match with color keywords (longer patterns first)
            for key in sorted_keys:
                key_normalized = key.replace('_', '').replace(' ', '')
                if key_normalized in col_lower:
                    col_colors[col] = color_map[key]
                    matched = True
                    break

            # If no match, assign default colors
            if not matched:
                if 'task' in col_lower or 'count' in col_lower:
                    # Use index-based colors for generic columns
                    idx = numeric_cols.index(col)
                    default_colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6']
                    col_colors[col] = default_colors[idx % len(default_colors)]
        
        return ChartConfig(
            chart_type="stacked_bar",
            x_axis=category_col,
            y_axis=numeric_cols,
            stacked_keys=numeric_cols,
            title=self._generate_title(query),
            description="Stacked bar chart showing completion status",
            colors=col_colors if col_colors else None
        )
    
    def _create_pie_chart_config(
        self, 
        query: str, 
        results: List[Dict[str, Any]], 
        string_cols: List[str], 
        numeric_cols: List[str]
    ) -> ChartConfig:
        """Create configuration for pie chart"""
        return ChartConfig(
            chart_type="pie",
            x_axis=string_cols[0] if string_cols else None,
            y_axis=[numeric_cols[0]] if numeric_cols else None,
            title=self._generate_title(query),
            description="Distribution breakdown"
        )
    
    def _create_line_chart_config(
        self, 
        query: str, 
        results: List[Dict[str, Any]], 
        columns: List[str], 
        numeric_cols: List[str]
    ) -> ChartConfig:
        """Create configuration for line chart (time series)"""
        time_col = next(
            (col for col in columns if any(
                keyword in col.lower() 
                for keyword in ['date', 'time', 'month', 'year']
            )),
            columns[0]
        )
        
        return ChartConfig(
            chart_type="line",
            x_axis=time_col,
            y_axis=numeric_cols,
            title=self._generate_title(query),
            description="Trend over time"
        )
    
    def _create_bar_chart_config(
        self, 
        query: str, 
        results: List[Dict[str, Any]], 
        string_cols: List[str], 
        numeric_cols: List[str]
    ) -> ChartConfig:
        """Create configuration for regular bar chart"""
        return ChartConfig(
            chart_type="bar",
            x_axis=string_cols[0] if string_cols else None,
            y_axis=[numeric_cols[0]] if numeric_cols else None,
            title=self._generate_title(query),
            description="Comparison chart"
        )
    
    def _generate_title(self, query: str) -> str:
        """Generate a chart title from the query"""
        # Capitalize first letter and ensure it ends properly
        title = query.strip()
        if title:
            title = title[0].upper() + title[1:]
            if not title.endswith('?'):
                title = title.rstrip('.!') + ' Analysis'
        return title


# Create singleton instance
visualization_service = VisualizationService()

