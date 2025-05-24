using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SoftwareSecurity.Domain.Models;
using SoftwareSecurity.Persistence.Converters;

namespace SoftwareSecurity.Persistence.Configurations;

public class ChatMessageConfiguration : IEntityTypeConfiguration<ChatMessageModel>
{
    public void Configure(EntityTypeBuilder<ChatMessageModel> builder)
    {
        builder.ToTable("ChatMessages");
        
        builder.HasKey(c => c.Id);

        builder.Property(c => c.Id)
            .HasConversion(new UlidToStringConverter())
            .IsRequired();
            
        builder.Property(c => c.SenderId)
            .HasConversion(new UlidToStringConverter())
            .IsRequired();
            
        builder.Property(c => c.ReceiverId)
            .HasConversion(new UlidToStringConverter())
            .IsRequired();
            
        builder.Property(c => c.Content)
            .IsRequired();
            
        builder.Property(c => c.Timestamp)
            .IsRequired();
            
        builder.Property(c => c.IsRead)
            .IsRequired();
        
        builder.HasOne(c => c.Sender)
            .WithMany(u => u.SentMessages)
            .HasForeignKey(c => c.SenderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(c => c.Receiver)
            .WithMany(u => u.ReceivedMessages)
            .HasForeignKey(c => c.ReceiverId)
            .OnDelete(DeleteBehavior.Restrict);
    }
} 