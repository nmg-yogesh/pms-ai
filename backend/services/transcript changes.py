#created a new file            
            
            
            # Detect procedural/'how-to' intent (not limited to admin roles)
            procedural_keywords = ('step', 'steps', 'how to', 'procedure', 'process to', 'how do i', 'how can i', 'create', 'raise')
            definition_keywords = ('what is', 'what are', 'define', 'definition', 'meaning of')

            query_lower = request.query.lower()
            is_procedural = any(k in query_lower for k in procedural_keywords)
            is_definition = any(k in query_lower for k in definition_keywords)

            # First handle definition queries (eg: 'what is a help ticket', 'what is a recurring task')
            if is_definition:
                from backend.utils.prompts import extract_definition_from_transcript

                # Decide subject baskets
                if 'help ticket' in query_lower or 'help-ticket' in query_lower or 'ticket' in query_lower:
                    subject_kw = ['help ticket', 'help-ticket', 'helpdesk ticket']
                    subject_label = 'Help Ticket'
                elif 'recurring task' in query_lower or 'recurring' in query_lower:
                    subject_kw = ['recurring task', 'recurring']
                    subject_label = 'Recurring Task'
                elif 'fms' in query_lower or 'workflow' in query_lower:
                    subject_kw = ['fms workflow', 'fms']
                    subject_label = 'FMS Workflow'
                else:
                    subject_kw = [request.query]
                    subject_label = request.query

                definition = extract_definition_from_transcript(subject_kw)

                if not definition:
                    # Fallback to OpenAI for a concise definition
                    definition = await openai_service.generate_definition(subject_label, role=request.role)

                if definition:
                    result_item = {"subject": subject_label, "definition": definition}

                    if session_id:
                        try:
                            await conversation_service.add_message(ConversationMessageCreate(
                                session_id=session_id,
                                message_type=MessageType.USER,
                                content=request.query,
                                query=request.query
                            ))

                            await conversation_service.add_message(ConversationMessageCreate(
                                session_id=session_id,
                                message_type=MessageType.ASSISTANT,
                                content=f"Definition: {subject_label} - {definition}",
                                query=request.query,
                                result_count=1
                            ))
                        except Exception as conv_error:
                            logger.warning(f"Failed to save definition conversation history: {conv_error}")

                    return AgenticQueryResponse(
                        success=True,
                        query=request.query,
                        sql_query=None,
                        results=[result_item],
                        explanation=definition,
                        result_count=1,
                        execution_time_ms=0,
                        error=None,
                        chart_config=None
                    )

            # Next handle procedural steps (allow for executives and other roles too)
            if is_procedural:
                # Try to extract steps from the transcript first
                from backend.utils.prompts import extract_steps_from_transcript

                steps = extract_steps_from_transcript(request.role, request.query)

                if not steps:
                    # Fallback to OpenAI to generate concise procedural steps
                    steps = await openai_service.generate_procedural_steps(request.query, role=request.role)

                if steps:
                    # Build response where results are the steps and result_count is number of steps
                    step_results = [{"step_number": i + 1, "instruction": s} for i, s in enumerate(steps)]

                    # Save conversation history if session is provided
                    if session_id:
                        try:
                            await conversation_service.add_message(ConversationMessageCreate(
                                session_id=session_id,
                                message_type=MessageType.USER,
                                content=request.query,
                                query=request.query
                            ))

                            await conversation_service.add_message(ConversationMessageCreate(
                                session_id=session_id,
                                message_type=MessageType.ASSISTANT,
                                content=f"Steps to {request.query}: \n" + '\n'.join(f"{i+1}. {s}" for i, s in enumerate(steps)),
                                query=request.query,
                                result_count=len(steps)
                            ))
                        except Exception as conv_error:
                            logger.warning(f"Failed to save procedural conversation history: {conv_error}")

                    return AgenticQueryResponse(
                        success=True,
                        query=request.query,
                        sql_query=None,
                        results=step_results,
                        explanation=f"There are {len(steps)} steps to {request.query}.",
                        result_count=len(steps),
                        execution_time_ms=0,
                        error=None,
                        chart_config=None
                    )
