import 'package:flutter/material.dart';

class DecisionDialog extends StatefulWidget {
  final String title;
  final String body;
  final bool approve;
  final Function(String remarks) onConfirm;

  const DecisionDialog({
    super.key,
    required this.title,
    required this.body,
    required this.approve,
    required this.onConfirm,
  });

  @override
  State<DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<DecisionDialog> {
  final TextEditingController _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color actionColor = widget.approve ? const Color(0xFF1CB55C) : const Color(0xFFE53935);
    final String label = widget.approve ? "Confirm Approval" : "Confirm Rejection";

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: actionColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.approve ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: actionColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 16),
              Text(
                widget.body,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                validator: (value) {
                  if (!widget.approve && (value == null || value.trim().isEmpty)) {
                    return "A justification is required for rejection.";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: widget.approve
                      ? "Remarks (Optional - e.g. Budget codes approved)"
                      : "Reason for rejection (MANDATORY)",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF6F8FB),
                  errorStyle: const TextStyle(color: Color(0xFFE53935)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: actionColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE53935)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                            widget.onConfirm(_remarksController.text);
                          }
                        },
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
