import React, { useMemo } from 'react';
import {
  BarChart,
  Bar,
  PieChart,
  Pie,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Cell
} from 'recharts';
import { ChartConfig } from '../types';

interface ChartVisualizationProps {
  data: Record<string, any>[];
  chartType?: 'bar' | 'stacked_bar' | 'pie' | 'line' | 'doughnut' | 'auto';
  chartConfig?: ChartConfig;
}

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8', '#82CA9D', '#FFC658', '#FF6B9D'];

const DEFAULT_COLORS: Record<string, string> = {
  completed: '#10b981',
  pending: '#f59e0b',
  not_completed: '#ef4444',
  done: '#10b981',
  not_done: '#ef4444',
  finished: '#10b981',
  incomplete: '#ef4444',
  active: '#3b82f6',
  inactive: '#6b7280',
  open: '#10b981',
  closed: '#ef4444',
  in_progress: '#f59e0b'
};

export const ChartVisualization: React.FC<ChartVisualizationProps> = ({
  data,
  chartType = 'auto',
  chartConfig
}) => {
  const { processedData, detectedType, xKey, yKeys, title, stackedKeys, colors } = useMemo(() => {
    if (!data || data.length === 0) {
      return {
        processedData: [],
        detectedType: 'bar',
        xKey: '',
        yKeys: [],
        title: '',
        stackedKeys: [],
        colors: {}
      };
    }

    // If we have chart config from backend, use it
    if (chartConfig) {
      let processed = data.map(item => {
        const processedItem: any = {};
        Object.keys(item).forEach(key => {
          const value = item[key];
          if (typeof value === 'string' && !isNaN(Number(value))) {
            processedItem[key] = Number(value);
          } else {
            processedItem[key] = value;
          }
        });
        return processedItem;
      });

      // Special handling for pie charts with single-row data
      // Transform from: [{in_progress_tickets: 3, completed_tickets: 41, ...}]
      // To: [{status: "In Progress", count: 3}, {status: "Completed", count: 41}, ...]
      if (chartConfig.chart_type === 'pie' && data.length === 1 && chartConfig.y_axis && chartConfig.y_axis.length > 1) {
        const transformedData: any[] = [];
        const row = processed[0];

        chartConfig.y_axis.forEach(label => {
          // Convert label to potential column name variations
          // "In Progress" -> ["in_progress", "in_progress_tickets", "inprogress"]
          const labelLower = label.toLowerCase().replace(/\s+/g, '_');
          const possibleKeys = [
            labelLower,
            `${labelLower}_tickets`,
            labelLower.replace(/_/g, ''),
            `${labelLower.replace(/_/g, '')}_tickets`
          ];

          // Find the matching column in the data
          let matchedKey = null;
          let matchedValue = null;

          for (const key of Object.keys(row)) {
            const keyLower = key.toLowerCase();
            if (possibleKeys.some(pk => keyLower === pk || keyLower.includes(pk))) {
              matchedKey = key;
              matchedValue = row[key];
              break;
            }
          }

          if (matchedKey && matchedValue != null) {
            const value = typeof matchedValue === 'string' ? Number(matchedValue) : matchedValue;
            if (!isNaN(value) && value >= 0) {
              transformedData.push({
                status: label,
                count: value
              });
            }
          }
        });

        if (transformedData.length >= 2) {
          return {
            processedData: transformedData,
            detectedType: chartConfig.chart_type,
            xKey: 'status',
            yKeys: ['count'],
            title: chartConfig.title || '',
            stackedKeys: chartConfig.stacked_keys || [],
            colors: chartConfig.colors || {}
          };
        }
      }

      return {
        processedData: processed,
        detectedType: chartConfig.chart_type,
        xKey: chartConfig.x_axis || '',
        yKeys: chartConfig.y_axis || [],
        title: chartConfig.title || '',
        stackedKeys: chartConfig.stacked_keys || [],
        colors: chartConfig.colors || {}
      };
    }

    // Fallback to auto-detection
    const keys = Object.keys(data[0]);

    const numericKeys = keys.filter(key =>
      typeof data[0][key] === 'number' || !isNaN(Number(data[0][key]))
    );
    const stringKeys = keys.filter(key =>
      typeof data[0][key] === 'string' || (typeof data[0][key] !== 'number' && isNaN(Number(data[0][key])))
    );

    let type = chartType;
    let xAxisKey = stringKeys[0] || keys[0];
    let yAxisKeys = [numericKeys[0] || keys[1] || keys[0]];

    if (chartType === 'auto') {
      if (data.length <= 10 && numericKeys.length === 1 && stringKeys.length === 1) {
        type = 'pie';
      } else if (xAxisKey.toLowerCase().includes('date') || xAxisKey.toLowerCase().includes('time')) {
        type = 'line';
      } else {
        type = 'bar';
      }
    }

    const processed = data.map(item => {
      const processedItem: any = {};
      Object.keys(item).forEach(key => {
        const value = item[key];
        if (typeof value === 'string' && !isNaN(Number(value))) {
          processedItem[key] = Number(value);
        } else {
          processedItem[key] = value;
        }
      });
      return processedItem;
    });

    return {
      processedData: processed,
      detectedType: type,
      xKey: xAxisKey,
      yKeys: yAxisKeys,
      title: '',
      stackedKeys: [],
      colors: {}
    };
  }, [data, chartType, chartConfig]);

  if (!processedData || processedData.length === 0) {
    return null;
  }

  // Helper to get color for a key
  const getColor = (key: string, index: number): string => {
    // First check custom colors from config
    if (colors && colors[key]) {
      return colors[key];
    }
    // Then check default colors
    const lowerKey = key.toLowerCase().replace(/_/g, '');
    if (DEFAULT_COLORS[lowerKey]) {
      return DEFAULT_COLORS[lowerKey];
    }
    // Fallback to color palette
    return COLORS[index % COLORS.length];
  };

  // Custom label for pie chart
  const renderCustomLabel = (entry: any) => {
    const name = entry[xKey] || entry.name;
    const value = yKeys.length > 0 ? entry[yKeys[0]] : entry.value;
    return `${name}: ${value}`;
  };

  const renderChart = () => {
    switch (detectedType) {
      case 'pie':
      case 'doughnut':
        return (
          <ResponsiveContainer width="100%" height={400}>
            <PieChart>
              <Pie
                data={processedData}
                dataKey={yKeys[0] || 'value'}
                nameKey={xKey || 'name'}
                cx="50%"
                cy="50%"
                outerRadius={detectedType === 'doughnut' ? 100 : 120}
                innerRadius={detectedType === 'doughnut' ? 70 : 0}
                fill="#8884d8"
                label={renderCustomLabel}
                labelLine={true}
              >
                {processedData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={getColor(entry[xKey] || '', index)} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        );

      case 'stacked_bar':
        return (
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={processedData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey={xKey}
                angle={-45}
                textAnchor="end"
                height={100}
              />
              <YAxis />
              <Tooltip />
              <Legend />
              {stackedKeys.map((key, index) => (
                <Bar
                  key={key}
                  dataKey={key}
                  stackId="a"
                  fill={getColor(key, index)}
                  name={key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                />
              ))}
            </BarChart>
          </ResponsiveContainer>
        );

      case 'line':
        return (
          <ResponsiveContainer width="100%" height={400}>
            <LineChart data={processedData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey={xKey} />
              <YAxis />
              <Tooltip />
              <Legend />
              {yKeys.map((key, index) => (
                <Line
                  key={key}
                  type="monotone"
                  dataKey={key}
                  stroke={getColor(key, index)}
                  strokeWidth={2}
                  name={key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                />
              ))}
            </LineChart>
          </ResponsiveContainer>
        );

      case 'bar':
      default:
        return (
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={processedData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey={xKey}
                angle={processedData.length > 5 ? -45 : 0}
                textAnchor={processedData.length > 5 ? "end" : "middle"}
                height={processedData.length > 5 ? 100 : 60}
              />
              <YAxis />
              <Tooltip />
              <Legend />
              {yKeys.map((key, index) => (
                <Bar
                  key={key}
                  dataKey={key}
                  fill={getColor(key, index)}
                  name={key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                />
              ))}
            </BarChart>
          </ResponsiveContainer>
        );
    }
  };

  return (
    <div className="mt-4 p-4 bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg border border-gray-200">
      {title && (
        <div className="mb-3 text-base font-semibold text-gray-800">
          📊 {title}
        </div>
      )}
      {!title && (
        <div className="mb-2 text-sm font-medium text-gray-700">
          Data Visualization
        </div>
      )}
      {renderChart()}
    </div>
  );
};

