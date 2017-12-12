# frozen_string_literal: true

module Analist
  class Annotation
    attr_reader :receiver_type, :args_types, :return_type, :hint

    def initialize(receiver_type, args_types, return_type, hint: nil)
      @receiver_type = receiver_type.is_a?(Hash) ? receiver_type : { type: receiver_type }
      @args_types = args_types
      @return_type = return_type.is_a?(Hash) ? return_type : { type: return_type }
      @hint = hint
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      attrs = %i[receiver_type args_types return_type]
      attrs.all? do |attr|
        send(attr) == other.send(attr)
      end
    end

    def to_s
      [receiver_type, args_types, return_type].to_s
    end
  end

  class AnnotationTypeUnknown; end
  class AnyArgs; end
  class Boolean; end

  module Annotations
    module_function

    def send_annotations # rubocop:disable Metrics/MethodLength
      {
        :+ => lambda do |receiver_return_type|
          {
            Integer => Annotation.new(Integer, [Integer], Integer),
            String => Annotation.new(String, [String], String),
            Array => Annotation.new(Array, [Array], Array)
          }[receiver_return_type[:type]]
        end,
        all: lambda do |receiver_return_type|
          Annotation.new(
            { type: receiver_return_type[:type], on: :collection },
            [],
            type: receiver_return_type[:type], on: :collection
          )
        end,
        decorate: lambda do |receiver_return_type|
          Annotation.new(
            receiver_return_type,
            [],
            type: :"#{receiver_return_type[:type]}Decorator", on: receiver_return_type[:on]
          )
        end,
        reverse: lambda do |receiver_return_type|
          {
            String => Annotation.new(String, [], String),
            Array => Annotation.new(Array, [], Array)
          }[receiver_return_type[:type]]
        end,
        upcase: ->(_) { Annotation.new(String, [], String) },
        new: lambda do |receiver_return_type|
               Annotation.new(
                 { type: receiver_return_type[:type], on: :collection },
                 [Analist::AnyArgs],
                 type: receiver_return_type[:type], on: :instance
               )
             end,
        include: ->(_) { Annotation.new(nil, [String], nil) },
        require: ->(_) { Annotation.new(nil, [String], nil) },
        each: lambda do |receiver_return_type|
                Annotation.new(
                  { type: receiver_return_type[:type], on: :collection },
                  Proc,
                  Analist::AnnotationTypeUnknown
                )
              end,
        present?: lambda do |receiver_return_type|
                    Annotation.new(
                      { type: receiver_return_type[:type], on: :instance },
                      [],
                      Analist::Boolean
                    )
                  end,
        private: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        to_s: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [],
                  String
                )
              end,
        raise: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        where: lambda do |receiver_return_type|
                 Annotation.new(
                   { type: receiver_return_type[:type], on: :collection },
                   [Hash],
                   type: receiver_return_type[:type], on: :collection
                 )
               end,
        map: lambda do |receiver_return_type|
               Annotation.new(
                 { type: receiver_return_type[:type], on: :collection },
                 Proc,
                 Analist::AnnotationTypeUnknown
               )
             end,
        join: lambda do |receiver_return_type|
                return_map = { Array => String }
                Annotation.new(
                  { type: receiver_return_type[:type], on: :collection },
                  [Analist::AnyArgs],
                  return_map.fetch(receiver_return_type[:type], Analist::AnnotationTypeUnknown)
                )
              end,
        render: ->(_) { Annotation.new(nil, [Hash || String], nil) },
        class: lambda do |receiver_return_type|
                 Annotation.new(
                   receiver_return_type,
                   [],
                   type: receiver_return_type[:type], on: :collection
                 )
               end,
        respond_to?: lambda do |receiver_return_type|
                       Annotation.new(
                         receiver_return_type,
                         Set.new([[Symbol], [String]]),
                         Analist::Boolean
                       )
                     end,
        to_i: ->(_) { Annotation.new(Analist::AnnotationTypeUnknown, [], Integer) },
        desc: ->(_) { Annotation.new(nil, [String], nil) },
        first: lambda do |receiver_return_type|
                 Annotation.new(
                   { type: receiver_return_type[:type], on: :collection },
                   [],
                   type: receiver_return_type[:type], on: :instance
                 )
               end,
        merge: lambda do |receiver_return_type|
                 Annotation.new(
                   receiver_return_type,
                   [receiver_return_type[:type]],
                   receiver_return_type
                 )
               end,
        freeze: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [],
                    receiver_return_type
                  )
                end,
        is_a?: lambda do |receiver_return_type|
                 Annotation.new(
                   receiver_return_type,
                   [Analist::AnyArgs],
                   Analist::Boolean
                 )
               end,
        puts: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        string: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [Analist::AnyArgs],
                    nil
                  )
                end,
        attr_reader: ->(_) { Annotation.new(nil, Set.new([[Symbol], [String]]), nil) },
        nil?: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [],
                  Analist::Boolean
                )
              end,
        integer: lambda do |receiver_return_type|
                   Annotation.new(
                     receiver_return_type,
                     [Analist::AnyArgs],
                     nil
                   )
                 end,
        add_index: ->(_) { Annotation.new(nil, [Symbol], nil) },
        gsub: ->(_) { Annotation.new(String, [Regexp, String], String) },
        optional: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        find: lambda do |receiver_return_type|
                Annotation.new(
                  { type: receiver_return_type[:type], on: :collection },
                  [Integer],
                  type: receiver_return_type[:type], on: :instance
                )
              end,
        autoload: ->(_) { Annotation.new(nil, [String || Symbol, String], nil) },
        find_by: lambda do |receiver_return_type|
                   Annotation.new(
                     { type: receiver_return_type[:type], on: :collection },
                     [Hash],
                     type: receiver_return_type[:type], on: :instance
                   )
                 end,
        empty?: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [],
                    Analist::Boolean
                  )
                end,
        blank?: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [],
                    Analist::Boolean
                  )
                end,
        extend: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [{ type: node.children.last, on: :collection }],
                    nil
                  )
                end,
        any?: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [],
                  Analist::Boolean
                )
              end,
        validates: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        before_action: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        redirect_to: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        belongs_to: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        success?: lambda do |receiver_return_type|
                    Annotation.new(
                      receiver_return_type,
                      [],
                      Analist::Boolean
                    )
                  end,
        dup: lambda do |receiver_return_type|
               Annotation.new(
                 receiver_return_type,
                 [],
                 receiver_return_type
               )
             end,
        errors: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [],
                    type: receiver_return_type[:type], on: :instance
                  )
                end,
        has_many: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        path: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [],
                  String
                )
              end,
        send: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  Set.new([[Symbol], [String]]),
                  Analist::AnnotationTypeUnknown
                )
              end,
        add_column: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        key?: ->(_) { Annotation.new(Hash, [Analist::AnyArgs], Analist::Boolean) },
        datetime: lambda do |receiver_return_type|
                    Annotation.new(
                      receiver_return_type,
                      [Analist::AnyArgs],
                      nil
                    )
                  end,
        size: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [],
                  Integer
                )
              end,
        count: lambda do |receiver_return_type|
                 Annotation.new(
                   receiver_return_type,
                   [Analist::AnyArgs],
                   Integer
                 )
               end,
        length: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [],
                    Integer
                  )
                end,
        split: lambda do |receiver_return_type|
                 Annotation.new(
                   receiver_return_type,
                   [Analist::AnyArgs],
                   Array
                 )
               end,
        attr_accessor: ->(_) { Annotation.new(nil, Set.new([[Symbol], [String]]), nil) },
        can?: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [Analist::AnyArgs],
                  Analist::Boolean
                )
              end,
        create_table: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        to_sym: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [],
                    Symbol
                  )
                end,
        text: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [Analist::AnyArgs],
                  nil
                )
              end,
        delegate: ->(_) { Annotation.new(nil, [Analist::AnyArgs], nil) },
        require_dependency: ->(_) { Annotation.new(nil, [String], nil) },
        disable_ddl_transaction!: ->(_) { Annotation.new(nil, [], nil) },
        alias_method: ->(_) { Annotation.new(nil, [Symbol, Symbol], nil) }

      }
    end

    def primitive_annotations
      {
        const: ->(node) { Annotation.new(nil, [], type: node.children.last, on: :collection) },
        dstr: ->(_) { Annotation.new(nil, [], String) },
        int: ->(_) { Annotation.new(nil, [], Integer) },
        regexp: ->(_) { Annotation.new(nil, [], Regexp) },
        str: ->(_) { Annotation.new(nil, [], String) },
        sym: ->(_) { Annotation.new(nil, [], Symbol) }
      }
    end
  end
end
