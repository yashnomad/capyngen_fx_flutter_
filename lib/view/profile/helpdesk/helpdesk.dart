// screens/helpdesk_support_screen.dart

import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../create_ticket/bloc/ticket_cubit.dart';
import '../create_ticket/create_ticket.dart';
import '../create_ticket/model/ticket_model.dart';

class HelpdeskSupportScreen extends StatelessWidget {
  const HelpdeskSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketCubit()..fetchTickets(),
      child: const HelpdeskSupportView(),
    );
  }
}

class HelpdeskSupportView extends StatelessWidget {
  const HelpdeskSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(
        title: 'Helpdesk',
        action: [
          BlocBuilder<TicketCubit, TicketState>(
            builder: (context, state) {
              if (state is TicketLoaded && state.tickets.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    context.read<TicketCubit>().refreshTickets();
                  },
                  icon: const Icon(Icons.refresh),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TicketCubit>().refreshTickets(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // Top Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColor.greenColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'English Helpdesk Support',
                      style: TextStyle(
                        color: AppColor.whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Get assistance with your questions and issues',
                      style: TextStyle(
                        color: AppColor.whiteColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content based on state
              Expanded(
                child: BlocConsumer<TicketCubit, TicketState>(
                  listener: (context, state) {
                    if (state is TicketError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is TicketLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is TicketLoaded) {
                      if (state.tickets.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      return _buildTicketsList(context, state.tickets);
                    }

                    if (state is TicketError) {
                      return _buildErrorState(context, state.message);
                    }

                    return _buildEmptyState(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            SlidePageRoute(
              page: BlocProvider.value(
                value: context.read<TicketCubit>(),
                child: const CreateTicket(),
              ),
            ),
          );

          // Refresh tickets if a new ticket was created
          if (result == true) {
            context.read<TicketCubit>().refreshTickets();
          }
        },
        backgroundColor: AppColor.greenColor,
        child: Icon(
          Icons.add,
          color: AppColor.whiteColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppColor.greenColor.withValues(alpha: 0.1),
            radius: 30,
            child: Icon(
              CupertinoIcons.chat_bubble_text_fill,
              color: AppColor.greenColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "You don't have any tickets",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start a conversation with our English support team by creating a ticket",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                SlidePageRoute(
                  page: BlocProvider.value(
                    value: context.read<TicketCubit>(),
                    child: const CreateTicket(),
                  ),
                ),
              );

              if (result == true) {
                context.read<TicketCubit>().refreshTickets();
              }
            },
            icon: Icon(
              Icons.add,
              size: 18,
              color: AppColor.whiteColor,
            ),
            label: Text(
              "Create New Ticket",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColor.whiteColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.greenColor,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTicketsList(BuildContext context, List<Ticket> tickets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Support Tickets (${tickets.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  SlidePageRoute(
                    page: BlocProvider.value(
                      value: context.read<TicketCubit>(),
                      child: const CreateTicket(),
                    ),
                  ),
                );

                if (result == true) {
                  context.read<TicketCubit>().refreshTickets();
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Ticket'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _buildTicketCard(context, ticket);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.ticketNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(ticket.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ticket.statusDisplayName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.subject,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.priority_high,
                    size: 14,
                    color: _getPriorityColor(ticket.priority),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ticket.priorityDisplayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getPriorityColor(ticket.priority),
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(ticket.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<TicketCubit>().fetchTickets();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }
}
