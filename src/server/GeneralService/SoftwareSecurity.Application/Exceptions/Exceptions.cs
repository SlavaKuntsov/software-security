namespace SoftwareSecurity.Application.Exceptions;

public class AlreadyExistsException(string message) : Exception(message) { }

public class BadRequestException(string message) : Exception(message) { }

public class NotFoundException(string message) : Exception(message) { }

public class ValidationProblemException(string message) : Exception(message) { }

public class InvalidTokenException(string message) : Exception(message) { }

public class UnprocessableContentException(string message) : Exception(message) { }