import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/app/theme/app_spacing.dart';
import 'package:imageflow/app/theme/app_text_styles.dart';
import 'package:imageflow/presentation/home/controllers/home_controller.dart';
import 'package:imageflow/presentation/home/widgets/empty_state_widget.dart';
import 'package:imageflow/presentation/home/widgets/history_item_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      body: Obx(() {
        if (controller.isLoading.value && controller.history.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.burrowingOwl),
          );
        }

        if (controller.history.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              Expanded(
                child: EmptyStateWidget(onCapture: controller.goToCapture),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                itemCount: controller.history.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) {
                  final record = controller.history[index];
                  return HistoryItemCard(
                    record: record,
                    onTap: () => controller.goToDetail(record),
                    onDelete: () => controller.deleteRecord(record.id),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToCapture,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Text('ImageFlow', style: AppTextStyles.titleSmall),
    );
  }
}
