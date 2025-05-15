import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:silk_route/app/utils/helpers.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:silk_route/controllers/admin_controller.dart';

class AdminAnalyticsView extends GetView<AdminController> {
  const AdminAnalyticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAnalytics(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingAnalytics.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshAnalytics,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTimeframeSelector(context),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildSalesChart(),
              const SizedBox(height: 24),
              _buildOrdersChart(),
              const SizedBox(height: 24),
              _buildShopCategoriesChart(),
              const SizedBox(height: 24),
              _buildUserGrowthChart(),
              const SizedBox(height: 24),
              _buildTopPerformers(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimeframeSelector(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Timeframe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: controller.selectedTimeframe.value,
                    items: [
                      'Today',
                      'Yesterday',
                      'Last 7 Days',
                      'Last 30 Days',
                      'This Month',
                      'Last Month',
                      'Custom Range',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        controller.selectedTimeframe.value = newValue;
                        if (newValue == 'Custom Range') {
                          _showDateRangePicker(context);
                        } else {
                          controller.updateAnalyticsTimeframe();
                        }
                      }
                    },
                  )),
                ),
                if (controller.selectedTimeframe.value == 'Custom Range') ...[
                  const SizedBox(width: 12),
                  Obx(() => TextButton(
                    onPressed: () => _showDateRangePicker(context),
                    child: Text(
                      '${DateFormat('MMM d').format(controller.startDate.value)} - '
                      '${DateFormat('MMM d').format(controller.endDate.value)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value,
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;
      controller.updateAnalyticsTimeframe();
    }
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          'Total Revenue',
          '₹${(controller.totalRevenue.value)}',
          Icons.currency_rupee,
          Colors.green.shade400,
          '${controller.revenueGrowth.value >= 0 ? '+' : ''}${controller.revenueGrowth.value.toStringAsFixed(1)}% vs previous',
          controller.revenueGrowth.value >= 0 ? Colors.green : Colors.red,
        ),
        _buildSummaryCard(
          'Total Orders',
          controller.totalOrders.value.toString(),
          Icons.shopping_bag,
          Colors.blue.shade400,
          '${controller.ordersGrowth.value >= 0 ? '+' : ''}${controller.ordersGrowth.value.toStringAsFixed(1)}% vs previous',
          controller.ordersGrowth.value >= 0 ? Colors.green : Colors.red,
        ),
        _buildSummaryCard(
          'Active Shops',
          controller.activeShops.value.toString(),
          Icons.store,
          Colors.purple.shade400,
          '${controller.shopsGrowth.value >= 0 ? '+' : ''}${controller.shopsGrowth.value.toStringAsFixed(1)}% vs previous',
          controller.shopsGrowth.value >= 0 ? Colors.green : Colors.red,
        ),
        _buildSummaryCard(
          'New Users',
          controller.newUsers.value.toString(),
          Icons.people,
          Colors.orange.shade400,
          '${controller.usersGrowth.value >= 0 ? '+' : ''}${controller.usersGrowth.value.toStringAsFixed(1)}% vs previous',
          controller.usersGrowth.value >= 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title, 
    String value, 
    IconData icon, 
    Color color,
    String subtitle,
    Color subtitleColor,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (controller.dailyRevenue.isEmpty) {
                  return const Center(child: Text('No revenue data available'));
                }
                
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('₹0');
                            if (value % 20000 == 0) {
                              return Text('₹${(value / 1000).toInt()}k');
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < controller.dailyRevenue.length) {
                              if (controller.dailyRevenue.length <= 7) {
                                return Text(
                                  DateFormat('MM/dd').format(controller.dailyRevenue[value.toInt()].date),
                                  style: const TextStyle(fontSize: 10),
                                );
                              } else if (value.toInt() % 3 == 0) {
                                return Text(
                                  DateFormat('MM/dd').format(controller.dailyRevenue[value.toInt()].date),
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                            }
                            return const Text('');
                          },
                          reservedSize: 28,
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                        left: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          controller.dailyRevenue.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            controller.dailyRevenue[index].revenue,
                          ),
                        ),
                        isCurved: true,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (controller.orderStatusDistribution.isEmpty) {
                  return const Center(child: Text('No order data available'));
                }
                
                return PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(
                      controller.orderStatusDistribution.length,
                      (index) {
                        final item = controller.orderStatusDistribution[index];
                        return PieChartSectionData(
                          color: _getOrderStatusColor(item.status),
                          value: item.count.toDouble(),
                          title: '${(item.count / controller.totalOrders.value * 100).toStringAsFixed(0)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: controller.orderStatusDistribution.map((item) => _buildLegendItem(
                item.status,
                _getOrderStatusColor(item.status),
                '${item.count} orders',
              )).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCategoriesChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: Obx(() {
                if (controller.shopCategoryDistribution.isEmpty) {
                  return const Center(child: Text('No shop category data available'));
                }
                
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: controller.shopCategoryDistribution
                        .map((item) => item.count)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${controller.shopCategoryDistribution[groupIndex].category}: ${rod.toY.toInt()}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < controller.shopCategoryDistribution.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  controller.shopCategoryDistribution[value.toInt()].category,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 42,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0');
                            if (value % 5 == 0) {
                              return Text(value.toInt().toString());
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: List.generate(
                      controller.shopCategoryDistribution.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: controller.shopCategoryDistribution[index].count.toDouble(),
                            color: _getCategoryColor(index),
                            width: 16,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Growth',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Obx(() {
                if (controller.userGrowthData.isEmpty) {
                  return const Center(child: Text('No user growth data available'));
                }
                
                return LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = controller.userGrowthData[spot.x.toInt()].date;
                            final count = spot.y.toInt();
                            final role = spot.barIndex == 0 ? 'Shop Owners' : 'Customers';
                            
                            return LineTooltipItem(
                              '${DateFormat('MM/dd').format(date)}\n$role: $count',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {},
                      handleBuiltInTouches: true,
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < controller.userGrowthData.length) {
                              if (controller.userGrowthData.length <= 7) {
                                return Text(
                                  DateFormat('MM/dd').format(controller.userGrowthData[value.toInt()].date),
                                  style: const TextStyle(fontSize: 10),
                                );
                              } else if (value.toInt() % 3 == 0) {
                                return Text(
                                  DateFormat('MM/dd').format(controller.userGrowthData[value.toInt()].date),
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value % 10 == 0) {
                              return Text(value.toInt().toString());
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                        left: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    lineBarsData: [
                      // Shop owners line
                      LineChartBarData(
                        spots: List.generate(
                          controller.userGrowthData.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            controller.userGrowthData[index].shopOwners.toDouble(),
                          ),
                        ),
                        isCurved: true,
                        color: Colors.purple,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.purple.withOpacity(0.2),
                        ),
                      ),
                      // Customers line
                      LineChartBarData(
                        spots: List.generate(
                          controller.userGrowthData.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            controller.userGrowthData[index].customers.toDouble(),
                          ),
                        ),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Shop Owners', Colors.purple, ''),
                const SizedBox(width: 24),
                _buildLegendItem('Customers', Colors.blue, ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformers() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performing Shops',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.topShopsData.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No shop data available'),
                  ),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.topShopsData.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final shopData = controller.topShopsData[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(shopData.name[0]),
                    ),
                    title: Text(shopData.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${shopData.city} • ${shopData.category}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${shopData.revenue}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text('${shopData.orders} orders'),
                      ],
                    ),
                    onTap: () => controller.goToShopDetails(shopData.id),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'delivering':
        return Colors.amber;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(int index) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    
    return colors[index % colors.length];
  }
}