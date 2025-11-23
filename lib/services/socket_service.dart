import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;

  // Getters
  bool get isConnected => _isConnected;
  io.Socket? get socket => _socket;

  // Initialize and connect to Socket.io server
  void connect() {
    if (_socket != null && _isConnected) {
      // ignore: avoid_print
      print('🔌 Socket already connected');
      return;
    }

    try {
      final String apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
      // ignore: avoid_print
      print('🔌 Attempting to connect to Socket.IO at: $apiUrl');

      // Configure socket connection
      _socket = io.io(
        apiUrl,
        io.OptionBuilder()
            .setTransports([
              'websocket',
              'polling'
            ]) // Try websocket first, fallback to polling
            .disableAutoConnect() // Manual connection control
            .enableReconnection() // Enable auto-reconnection
            .setReconnectionAttempts(5) // Retry 5 times
            .setReconnectionDelay(2000) // Wait 2s between retries
            .setReconnectionDelayMax(5000) // Max delay 5s
            .enableForceNew() // Force new connection
            .build(),
      );

      // Connection event handlers
      _socket!.onConnect((_) {
        _isConnected = true;
        // ignore: avoid_print
        print('✅ Socket connected successfully to $apiUrl');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        // ignore: avoid_print
        print('❌ Socket disconnected');
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        // ignore: avoid_print
        print('⚠️ Socket connection error: $error');
      });

      _socket!.onError((error) {
        // ignore: avoid_print
        print('🚨 Socket error: $error');
      });

      _socket!.onReconnect((attempt) {
        // ignore: avoid_print
        print('🔄 Socket reconnecting... Attempt: $attempt');
      });

      _socket!.onReconnectError((error) {
        // ignore: avoid_print
        print('⚠️ Socket reconnection error: $error');
      });

      _socket!.onReconnectFailed((_) {
        // ignore: avoid_print
        print('❌ Socket reconnection failed after all attempts');
      });

      // Debug: Listen to ALL events to see what's being emitted
      _socket!.onAny((event, data) {
        // ignore: avoid_print
        print('🔔 Socket event received: $event with data: $data');
      });

      // Connect to server
      _socket!.connect();
    } catch (e) {
      // ignore: avoid_print
      print('🚨 Failed to initialize socket: $e');
    }
  }

  // Listen to requirement creation events
  void onRequirementCreated(Function(dynamic) callback) {
    if (_socket == null) {
      // ignore: avoid_print
      print('⚠️ Socket not initialized. Call connect() first.');
      return;
    }

    _socket!.on('requirement:created', (data) {
      // ignore: avoid_print
      print('📨 Received requirement:created event');
      callback(data);
    });
  }

  // Listen to requirement update events (status changes like signed/unsigned)
  void onRequirementUpdated(Function(dynamic) callback) {
    if (_socket == null) {
      // ignore: avoid_print
      print('⚠️ Socket not initialized. Call connect() first.');
      return;
    }

    _socket!.on('studentRequirementUpdated', (data) {
      // ignore: avoid_print
      print('📨 Received studentRequirementUpdated event');
      callback(data);
    });
  }

  // Listen to requirement deletion events
  void onRequirementDeleted(Function(dynamic) callback) {
    if (_socket == null) {
      // ignore: avoid_print
      print('⚠️ Socket not initialized. Call connect() first.');
      return;
    }

    _socket!.on('requirement:deleted', (data) {
      // ignore: avoid_print
      print('📨 Received requirement:deleted event');
      callback(data);
    });
  }

  // ========== INSTITUTIONAL REQUIREMENT LISTENERS ==========

  // Listen to institutional requirement creation events
  void onInstitutionalRequirementCreated(Function(dynamic) callback) {
    if (_socket == null) {
      // ignore: avoid_print
      print('⚠️ Socket not initialized. Call connect() first.');
      return;
    }

    _socket!.on('institutional:requirement:created', (data) {
      // ignore: avoid_print
      print('📨 Received institutional:requirement:created event');
      callback(data);
    });
  }

  // Listen to institutional student requirement update events
  void onInstitutionalRequirementUpdated(Function(dynamic) callback) {
    if (_socket == null) {
      // ignore: avoid_print
      print('⚠️ Socket not initialized. Call connect() first.');
      return;
    }

    _socket!.on('institutional:studentRequirementUpdated', (data) {
      // ignore: avoid_print
      print('📨 Received institutional:studentRequirementUpdated event');
      callback(data);
    });
  }

  // Listen to institutional requirement deletion events
  void onInstitutionalRequirementDeleted(Function(dynamic) callback) {
    if (_socket == null) {
      // ignore: avoid_print
      print('⚠️ Socket not initialized. Call connect() first.');
      return;
    }

    _socket!.on('institutional:requirement:deleted', (data) {
      // ignore: avoid_print
      print('📨 Received institutional:requirement:deleted event');
      callback(data);
    });
  }

  // ========== QR CODE LISTENERS ==========

  // Listen to all requirements cleared event
  void onAllRequirementsCleared(Function(dynamic) callback) {
    if (_socket == null) {
      // ignore: avoid_print
      print('⚠️ Socket not initialized. Call connect() first.');
      return;
    }

    _socket!.on('requirements:allCleared', (data) {
      // ignore: avoid_print
      print('📨 Received requirements:allCleared event');
      // ignore: avoid_print
      print('📊 Data: $data');
      callback(data);
    });
  }

  // Listen to QR code generation events
  void onQrGenerated(Function(dynamic) callback) {
    if (_socket == null) {
      // ignore: avoid_print
      print('⚠️ Socket not initialized. Call connect() first.');
      return;
    }

    _socket!.on('qr:generated', (data) {
      // ignore: avoid_print
      print('📨 Received qr:generated event');
      callback(data);
    });
  }

  // Remove specific event listener
  void off(String event) {
    if (_socket == null) return;
    _socket!.off(event);
    // ignore: avoid_print
    print('🔇 Removed listener for event: $event');
  }

  // Disconnect and cleanup
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      // ignore: avoid_print
      print('🔌 Socket disconnected and disposed');
    }
  }

  // Reconnect manually
  void reconnect() {
    if (_socket != null) {
      _socket!.connect();
      // ignore: avoid_print
      print('🔄 Manual socket reconnection initiated');
    } else {
      connect();
    }
  }
}
