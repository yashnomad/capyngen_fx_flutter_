// models/ticket_model.dart

class TicketResponse {
  final bool success;
  final TicketData data;

  TicketResponse({
    required this.success,
    required this.data,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      success: json['success'] ?? false,
      data: TicketData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class TicketData {
  final List<Ticket> tickets;
  final Pagination pagination;

  TicketData({
    required this.tickets,
    required this.pagination,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      tickets: (json['tickets'] as List<dynamic>?)
          ?.map((ticket) => Ticket.fromJson(ticket))
          .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tickets': tickets.map((ticket) => ticket.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class Ticket {
  final String id;
  final String ticketNumber;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String user;
  final List<dynamic> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.user,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] ?? '',
      ticketNumber: json['ticketNumber'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      user: json['user'] ?? '',
      attachments: json['attachments'] ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ticketNumber': ticketNumber,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
      'user': user,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }

  // Helper methods for status display
  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'new':
        return 'New';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  String get priorityDisplayName {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'pages': pages,
    };
  }
}

// Create ticket request model
class CreateTicketRequest {
  final String subject;
  final String description;
  final String? attachments; // For file upload

  CreateTicketRequest({
    required this.subject,
    required this.description,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
      if (attachments != null) 'attachments': attachments,
    };
  }
}

// Single ticket response for create operations
class SingleTicketResponse {
  final bool success;
  final Ticket data;

  SingleTicketResponse({
    required this.success,
    required this.data,
  });

  factory SingleTicketResponse.fromJson(Map<String, dynamic> json) {
    return SingleTicketResponse(
      success: json['success'] ?? false,
      data: Ticket.fromJson(json['data'] ?? {}),
    );
  }
}