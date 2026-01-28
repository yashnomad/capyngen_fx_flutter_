// cubit/ticket_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../network/api_service.dart';
import '../model/ticket_model.dart';


// States
abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketCreating extends TicketState {}

class TicketLoaded extends TicketState {
  final List<Ticket> tickets;
  final Pagination pagination;

  const TicketLoaded({
    required this.tickets,
    required this.pagination,
  });

  @override
  List<Object?> get props => [tickets, pagination];

  TicketLoaded copyWith({
    List<Ticket>? tickets,
    Pagination? pagination,
  }) {
    return TicketLoaded(
      tickets: tickets ?? this.tickets,
      pagination: pagination ?? this.pagination,
    );
  }
}

class TicketError extends TicketState {
  final String message;

  const TicketError(this.message);

  @override
  List<Object?> get props => [message];
}

class TicketCreated extends TicketState {
  final Ticket ticket;

  const TicketCreated(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

// Cubit
class TicketCubit extends Cubit<TicketState> {
  TicketCubit() : super(TicketInitial());

  // Fetch all tickets
  Future<void> fetchTickets({int page = 1, int limit = 10}) async {
    try {
      emit(TicketLoading());

      final response = await ApiService.fetchTicket();

      if (response.success == true) {
        final ticketResponse = TicketResponse.fromJson(response.data ?? {}) ;
        emit(TicketLoaded(
          tickets: ticketResponse.data.tickets,
          pagination: ticketResponse.data.pagination,
        ));
      } else {
        emit(const TicketError('Failed to fetch tickets'));
      }
    } catch (e) {
      emit(TicketError('Error fetching tickets: ${e.toString()}'));
    }
  }

  // Create a new ticket
  Future<bool> createTicket({
    required String subject,
    required String description,
    PlatformFile? attachmentFile,
  }) async {
    try {
      emit(TicketCreating());

      // Prepare the ticket data
      Map<String, dynamic> ticketData = {
        'subject': subject,
        'description': description,
      };

      // Handle file attachment if provided
      if (attachmentFile != null) {
        // For multipart form data, you might need to handle this differently
        // depending on your ApiService implementation
        ticketData['attachments'] = attachmentFile;
      }

      final response = await ApiService.createTicket(ticketData);

      if (response.success == true) {
        // Parse the new ticket
        final newTicket = Ticket.fromJson(response.data ?? {});

        // Update the current state by adding the new ticket
        if (state is TicketLoaded) {
          final currentState = state as TicketLoaded;
          final updatedTickets = [newTicket, ...currentState.tickets];
          final updatedPagination = currentState.pagination.copyWith(
            total: currentState.pagination.total + 1,
          );

          emit(TicketLoaded(
            tickets: updatedTickets,
            pagination: updatedPagination,
          ));
        } else {
          // If no tickets were loaded before, create a new state
          emit(TicketLoaded(
            tickets: [newTicket],
            pagination: Pagination(total: 1, page: 1, limit: 10, pages: 1),
          ));
        }

        emit(TicketCreated(newTicket));
        return true;
      } else {
        emit(const TicketError('Failed to create ticket'));
        return false;
      }
    } catch (e) {
      emit(TicketError('Error creating ticket: ${e.toString()}'));
      return false;
    }
  }

  // Refresh tickets (useful for pull-to-refresh)
  Future<void> refreshTickets() async {
    await fetchTickets();
  }

  // Load more tickets (for pagination)
  Future<void> loadMoreTickets() async {
    if (state is TicketLoaded) {
      final currentState = state as TicketLoaded;
      if (currentState.pagination.page < currentState.pagination.pages) {
        try {
          final response = await ApiService.fetchTicket();

          if (response.success == true) {
            final ticketResponse = TicketResponse.fromJson(response.data ?? {});
            final allTickets = [
              ...currentState.tickets,
              ...ticketResponse.data.tickets,
            ];

            emit(TicketLoaded(
              tickets: allTickets,
              pagination: ticketResponse.data.pagination,
            ));
          }
        } catch (e) {
          // Handle error without changing the current state
          emit(TicketError('Error loading more tickets: ${e.toString()}'));
        }
      }
    }
  }

  // Get ticket by ID (helper method)
  Ticket? getTicketById(String ticketId) {
    if (state is TicketLoaded) {
      final currentState = state as TicketLoaded;
      try {
        return currentState.tickets.firstWhere((ticket) => ticket.id == ticketId);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Check if there are any tickets
  bool hasTickets() {
    if (state is TicketLoaded) {
      final currentState = state as TicketLoaded;
      return currentState.tickets.isNotEmpty;
    }
    return false;
  }

  // Get tickets count
  int getTicketsCount() {
    if (state is TicketLoaded) {
      final currentState = state as TicketLoaded;
      return currentState.tickets.length;
    }
    return 0;
  }

  // Reset state
  void reset() {
    emit(TicketInitial());
  }
}

// Extension for Pagination copyWith
extension PaginationExtension on Pagination {
  Pagination copyWith({
    int? total,
    int? page,
    int? limit,
    int? pages,
  }) {
    return Pagination(
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      pages: pages ?? this.pages,
    );
  }
}