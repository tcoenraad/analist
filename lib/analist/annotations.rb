# frozen_string_literal: true

module Analist
  class Annotation
    attr_reader :receiver_type, :args_types, :return_type, :hint

    def initialize(receiver_type, args_types, return_type, hint: nil)
      @receiver_type = receiver_type.is_a?(Hash) ? receiver_type : { type: receiver_type }
      @args_types = self.class.initialize_args_types(args_types)
      @return_type = return_type.is_a?(Hash) ? return_type : { type: return_type }
      @hint = hint
    end

    def self.initialize_args_types(args_types)
      if args_types.is_a?(Set)
        return Set.new(args_types.map do |set|
          initialize_args_types(set)
        end)
      end
      args_types.map { |arg_type| arg_type.is_a?(Hash) ? arg_type : { type: arg_type } }
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

    class TypeUnknown; end
    class AnyArgs; end
    class AnyClass; end
    class Boolean; end

    UNKNOWN_ANNOTATION_TYPE = Analist::Annotation.new(Analist::Annotation::TypeUnknown,
                                                      [Analist::Annotation::AnyArgs],
                                                      Analist::Annotation::TypeUnknown).freeze
  end

  module Annotations # rubocop:disable Metrics/ModuleLength
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
                 [Analist::Annotation::AnyArgs],
                 type: receiver_return_type[:type], on: :instance
               )
             end,
        include: lambda do |receiver_return_type|
          {
            nil => Annotation.new(nil, [Annotation::AnyClass], nil)
          }.fetch(receiver_return_type[:type], Annotation::UNKNOWN_ANNOTATION_TYPE)
        end,
        require: lambda do |receiver_return_type|
          { nil: Annotation.new(nil, [String], nil) }.fetch(receiver_return_type,
                                                            Annotation::UNKNOWN_ANNOTATION_TYPE)
        end,
        each: lambda do |receiver_return_type|
                Annotation.new(
                  { type: receiver_return_type[:type], on: :collection },
                  [Proc],
                  Analist::Annotation::TypeUnknown
                )
              end,
        present?: lambda do |receiver_return_type|
                    Annotation.new(
                      { type: receiver_return_type[:type], on: :instance },
                      [],
                      Analist::Annotation::Boolean
                    )
                  end,
        private: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
        to_s: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  Set.new([[], [Integer]]),
                  String
                )
              end,
        raise: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
        where: lambda do |receiver_return_type|
                 Annotation.new(
                   { type: receiver_return_type[:type], on: :collection },
                   Set.new([[],
                            [Array],
                            [String, Hash],
                            [String],
                            [String, String],
                            [String, String, String]]), # TODO: support countless arguments
                   type: receiver_return_type[:type], on: :collection
                 )
               end,
        map: lambda do |receiver_return_type|
               Annotation.new(
                 { type: receiver_return_type[:type], on: :collection },
                 [],
                 type: receiver_return_type[:type], on: :collection
               )
             end,
        join: lambda do |receiver_return_type|
                return_map = { Array => String }
                Annotation.new(
                  { type: receiver_return_type[:type], on: :collection },
                  [Analist::Annotation::AnyArgs],
                  return_map.fetch(receiver_return_type[:type], Analist::Annotation::TypeUnknown)
                )
              end,
        render: ->(_) { Annotation.new(nil, Set.new([[Hash], [String]]), nil) },
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
                         Analist::Annotation::Boolean
                       )
                     end,
        to_i: ->(_) { Annotation.new(Analist::Annotation::TypeUnknown, [], Integer) },
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
          {
            collection: Annotation::UNKNOWN_ANNOTATION_TYPE
          }.fetch(receiver_return_type[:on],
                  Annotation.new(receiver_return_type, [], receiver_return_type))
        end,
        is_a?: lambda do |receiver_return_type|
                 Annotation.new(
                   receiver_return_type,
                   [Analist::Annotation::AnyArgs],
                   Analist::Annotation::Boolean
                 )
               end,
        puts: lambda do |receiver_return_type|
          receiver_return_node = { STDERR: { type: :STDERR, on: :collection } }.fetch(
            receiver_return_type[:type], nil
          )
          Annotation.new(receiver_return_node, [Analist::Annotation::AnyArgs], nil)
        end,
        string: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [Analist::Annotation::AnyArgs],
                    nil
                  )
                end,
        attr_reader: lambda do |_| # TODO: support countless arguments
          Annotation.new(nil, Set.new([[Symbol], [Symbol, Symbol], [Symbol, Symbol, Symbol],
                                       [Symbol, Symbol, Symbol, Symbol], [String]]), nil)
        end,
        nil?: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [],
                  Analist::Annotation::Boolean
                )
              end,
        integer: lambda do |receiver_return_type|
                   Annotation.new(
                     receiver_return_type,
                     [Analist::Annotation::AnyArgs],
                     nil
                   )
                 end,
        add_index: ->(_) { Annotation.new(nil, [Symbol], nil) },
        gsub: lambda do |_|
          Annotation.new(String, Set.new([[Regexp, String], [Regexp], [String, String]]), String)
        end,
        optional: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
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
                    Analist::Annotation::Boolean
                  )
                end,
        blank?: lambda do |receiver_return_type|
                  Annotation.new(
                    receiver_return_type,
                    [],
                    Analist::Annotation::Boolean
                  )
                end,
        any?: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [],
                  Analist::Annotation::Boolean
                )
              end,
        validates: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
        before_action: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
        redirect_to: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
        belongs_to: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
        success?: lambda do |receiver_return_type|
                    Annotation.new(
                      receiver_return_type,
                      [],
                      Analist::Annotation::Boolean
                    )
                  end,
        dup: lambda do |receiver_return_type|
               Annotation.new(
                 receiver_return_type,
                 [],
                 receiver_return_type
               )
             end,
        has_many: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
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
                  Analist::Annotation::TypeUnknown
                )
              end,
        add_column: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
        key?: lambda do |_|
          Annotation.new(Hash, [Analist::Annotation::AnyArgs], Analist::Annotation::Boolean)
        end,
        datetime: lambda do |receiver_return_type|
                    Annotation.new(
                      receiver_return_type,
                      [Analist::Annotation::AnyArgs],
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
                   [Analist::Annotation::AnyArgs],
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
                   [Analist::Annotation::AnyArgs],
                   type: Array, on: :collection
                 )
               end,
        attr_accessor: ->(_) { Annotation.new(nil, Set.new([[Symbol], [String]]), nil) },
        can?: lambda do |receiver_return_type|
                Annotation.new(
                  receiver_return_type,
                  [Analist::Annotation::AnyArgs],
                  Analist::Annotation::Boolean
                )
              end,
        create_table: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
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
                  [Analist::Annotation::AnyArgs],
                  nil
                )
              end,
        delegate: ->(_) { Annotation.new(nil, [Analist::Annotation::AnyArgs], nil) },
        require_dependency: ->(_) { Annotation.new(nil, [String], nil) },
        disable_ddl_transaction!: ->(_) { Annotation.new(nil, [], nil) },
        alias_method: ->(_) { Annotation.new(nil, [Symbol, Symbol], nil) }
      }
    end

    def primitive_annotations
      {
        block_pass: ->(_) { Annotation.new(nil, [], Proc) },
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
